extends CharacterBody3D
class_name HunterRobot

@onready var audio_player = $AudioStreamPlayer3D
@onready var door_mesh = $"../Office/LeftDoor" # Target door mesh to rotate

enum State {
	PATROLLING,
	APPROACHING,
	DOOR_RATTLE,
	BREAKING_IN
}

var current_state = State.PATROLLING
var patrol_dir: int = 1
var speed: float = 1.2

# Position track
# Corridor runs along X from -15 to -3.1, at Z = 1.5
var start_x: float = -15.0
var door_x: float = -3.1
var target_z: float = 1.5

# Sit/stand location of player inside office
var player_office_pos: Vector3 = Vector3(0.0, 1.0, 0.5)

# Timer variables
var footstep_timer: float = 0.0
var footstep_delay: float = 0.9 # Time between footsteps
var state_timer: float = 0.0
var wait_at_door_timer: float = 0.0

# Banging variables
var bang_count: int = 0

# Procedural audio assets
var step_stream: AudioStreamWAV
var screech_stream: AudioStreamWAV
var rattle_stream: AudioStreamWAV

# Logic timers
var next_investigation_time: float = 20.0 # Starts first patrol
var is_active: bool = false
var patrol_laps: int = 0
var warning_played: bool = false

func _ready():
	# Generate procedural sounds
	step_stream = _generate_clank_sound()
	screech_stream = _generate_screech_sound()
	rattle_stream = _generate_rattle_sound()
	
	audio_player.unit_size = 4.0
	audio_player.max_db = 3.0
	
	global_position = Vector3(start_x, 1.0, target_z)

func _physics_process(delta):
	# Hunter is completely inactive on Day 1 no matter what
	if GameStats.current_day <= 1:
		global_position = Vector3(start_x, 1.0, target_z)
		current_state = State.PATROLLING
		patrol_laps = 4
		$Sprite3D.visible = false
		is_active = false
		return

	# Calculate danger level based on let_through_bad_sprites and current day
	var danger_level = GameStats.let_through_bad_sprites.size()
	if GameStats.current_day == 2:
		danger_level = max(1, danger_level)
	elif GameStats.current_day >= 3:
		danger_level = max(2, danger_level)
		
	# Manage visibility: visible ONLY during door rattle, breaking in, or jumpscare
	var show_sprite = false
	if current_state == State.DOOR_RATTLE or current_state == State.BREAKING_IN:
		show_sprite = true
	$Sprite3D.visible = show_sprite
	
	# Activate robot on first active day
	if not is_active:
		is_active = true
		var day_multiplier = 1.0
		if GameStats.current_day == 2:
			day_multiplier = 0.75
		elif GameStats.current_day >= 3:
			day_multiplier = 0.5
		next_investigation_time = randf_range(30.0, 60.0) * day_multiplier
		warning_played = false
		if GameStats.let_through_bad_sprites.size() > 0:
			$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
			
	# Dynamically scale speeds based on threat count and current day
	var day_factor = (GameStats.current_day - 1) * 0.25
	speed = (1.1 + day_factor) + danger_level * 0.45
	
	# Manage active timers
	if current_state == State.PATROLLING:
		next_investigation_time -= delta
		if next_investigation_time <= 3.0 and not warning_played:
			warning_played = true
			audio_player.stream = screech_stream
			audio_player.pitch_scale = 0.75
			audio_player.play()
			
	# State Machine Logic
	match current_state:
		State.PATROLLING:
			handle_patrol(delta)
		State.APPROACHING:
			handle_approaching(delta)
		State.DOOR_RATTLE:
			handle_door_rattle(delta)
		State.BREAKING_IN:
			handle_breaking_in(delta)

	# Handle footstep audio timing
	handle_footsteps(delta)

func handle_patrol(delta):
	# Remain stationary at the starting point in the far corridor
	global_position.x = start_x
	global_position.z = target_z
	
	# Check if it's time to investigate (approach)
	if next_investigation_time <= 0:
		start_approach()

func start_approach():
	current_state = State.APPROACHING
	warning_played = false

func handle_approaching(delta):
	# Move directly to the door
	if global_position.x < door_x:
		global_position.x = move_toward(global_position.x, door_x, speed * 1.5 * delta)
		global_position.z = target_z
	else:
		# Arrived at the door
		current_state = State.DOOR_RATTLE
		wait_at_door_timer = 2.0
		if audio_player.stream != rattle_stream or not audio_player.playing:
			audio_player.stream = rattle_stream
			audio_player.play()

func handle_door_rattle(delta):
	# If player spots the Hunter on CCTV or through the window, it retreats!
	if check_if_player_sees_hunter():
		retreat_and_reset()
		return

	wait_at_door_timer -= delta
	if wait_at_door_timer <= 0:
		if GameStats.door_locked:
			current_state = State.BREAKING_IN
			bang_count = 0
			state_timer = 1.0 # time until first bang
		else:
			kill_player()

func handle_breaking_in(delta):
	# If player unlocks the door during breaking in, Hunter enters and jumpscares immediately
	if not GameStats.door_locked:
		kill_player()
		return
		
	state_timer -= delta
	if state_timer <= 0:
		# Bang on the door
		audio_player.stream = screech_stream
		audio_player.pitch_scale = randf_range(0.4, 0.6) # Low pitch thud/bang sound
		audio_player.play()
		
		# Drain power
		GameStats.power_level = max(0.0, GameStats.power_level - 15.0)
		bang_count += 1
		
		# Check if we trip the breaker or break in
		if bang_count >= 3 or GameStats.power_level <= 0:
			var game_3d = get_parent_node_3d()
			if game_3d and game_3d.has_method("trigger_breaker_outage"):
				game_3d.trigger_breaker_outage() # This automatically sets door_locked to false
			kill_player()
		else:
			# Schedule next bang
			state_timer = randf_range(1.5, 3.5)

func check_if_player_sees_hunter() -> bool:
	var game_3d = get_parent_node_3d()
	if not game_3d:
		return false
		
	var player = game_3d.get_node_or_null("Player")
	if not player:
		return false
		
	# 1. Check if player is viewing CCTV Camera app on computer
	if player.current_state == player.State.COMPUTER_VIEW and game_3d.is_monitor_on:
		var cctv_win = get_tree().root.find_child("CCTVWindow", true, false)
		if cctv_win and cctv_win.visible:
			return true
			
	# 2. Check if player is looking directly at the glass window in 3D
	if player.current_state != player.State.COMPUTER_VIEW:
		if not game_3d.is_curtain_closed:
			var camera = player.get_node_or_null("Camera3D")
			if camera:
				var window_pos = Vector3(0.0, 1.3, -1.54) # Center of the glass window
				var dir_to_window = (window_pos - camera.global_position).normalized()
				var camera_forward = -camera.global_transform.basis.z.normalized()
				var dot = camera_forward.dot(dir_to_window)
				# 0.7 dot product threshold corresponds to roughly a 45-degree angle pointing towards the window
				if dot > 0.7:
					return true
					
	return false

func retreat_and_reset():
	current_state = State.PATROLLING
	global_position = Vector3(start_x, 1.0, target_z)
	
	# Set a new investigation cooldown
	var danger_level = GameStats.let_through_bad_sprites.size()
	var freq_multiplier = max(0.35, 1.0 - (danger_level - 1) * 0.25)
	var day_multiplier = 1.0
	if GameStats.current_day == 2:
		day_multiplier = 0.75
	elif GameStats.current_day >= 3:
		day_multiplier = 0.5
	next_investigation_time = randf_range(40.0, 70.0) * freq_multiplier * day_multiplier
	warning_played = false
	
	# Play rapid footsteps walking away quickly (pitch_scale = 1.4)
	audio_player.stream = step_stream
	audio_player.pitch_scale = 1.4
	audio_player.play()

func kill_player():
	# Make sure sprite is visible
	$Sprite3D.visible = true
	
	# Play jumpscare sound
	audio_player.stream = screech_stream
	audio_player.pitch_scale = 1.0
	audio_player.play()
	
	# Swing door open physically
	if door_mesh:
		door_mesh.rotation.y = deg_to_rad(90.0)
	
	# Trigger game over after brief freeze
	await get_tree().create_timer(1.2).timeout
	
	if door_mesh:
		door_mesh.rotation.y = 0.0
		
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")

func handle_footsteps(delta):
	footstep_timer -= delta
	if footstep_timer <= 0:
		var danger_level = GameStats.let_through_bad_sprites.size()
		var step_multiplier = max(0.5, 1.0 - (danger_level - 1) * 0.15)
		footstep_delay = 0.95 * step_multiplier
		footstep_timer = footstep_delay
		
		var is_moving = true
		if current_state == State.DOOR_RATTLE or current_state == State.BREAKING_IN:
			is_moving = false
		elif current_state == State.PATROLLING:
			is_moving = false
			
		if is_moving:
			audio_player.stream = step_stream
			audio_player.pitch_scale = randf_range(0.85, 1.15)
			audio_player.play()

# === PROCEDURAL AUDIO GENERATION ===

func _generate_clank_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 3000 # ~0.27s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-22.0 * t)
		var val = sin(2.0 * PI * 75.0 * t) * 0.45 + sin(2.0 * PI * 210.0 * t) * 0.3 + (randf() - 0.5) * 0.18
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream

func _generate_screech_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 12000 # ~1.1s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 600.0 + sin(2.0 * PI * 8.0 * t) * 250.0
		var val = sin(2.0 * PI * freq * t) * 0.7 + (randf() - 0.5) * 0.25
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream

func _generate_rattle_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 8000 # ~0.72s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var rattle_env = abs(sin(2.0 * PI * 18.0 * t))
		var env = exp(-35.0 * fmod(t, 0.05)) * rattle_env
		var val = (randf() - 0.5) * 0.8
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream
