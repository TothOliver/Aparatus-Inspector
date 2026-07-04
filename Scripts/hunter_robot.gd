extends CharacterBody3D
class_name HunterRobot

# --- MODULAR NODE EXPORTS (Assign in Inspector for custom maps) ---
@export_group("Modular Markers")
@export var start_marker: Marker3D      # Far corridor starting/idle point
@export var door_marker: Marker3D       # Point directly outside the office door
@export var window_marker: Node3D       # The glass window node (used for sight check)
@export var window_peek_marker: Marker3D # Where the Hunter stands to peek through the window
@export var camera_peek_marker: Marker3D # Where the Hunter stands to be seen by the CCTV camera
@export var jumpscare_marker: Marker3D  # Where the Hunter warps to jumpscare the player

@export_group("Modular Mesh & Audio overrides")
@export var door_mesh_override: Node3D  # The door mesh to swing open
@export var custom_audio_player: AudioStreamPlayer3D # Audio override (defaults to child)

@onready var audio_player = $AudioStreamPlayer3D
@onready var door_mesh = $"../Office/LeftDoor" # Default scene fallback

enum State {
	PATROLLING,
	APPROACHING,
	DOOR_RATTLE,
	BREAKING_IN
}

enum PeekLocation {
	DOOR,
	WINDOW,
	CAMERA
}

var current_state = State.PATROLLING
var speed: float = 1.2
var active_peek_location = PeekLocation.DOOR

# --- BACKWARD COMPATIBILITY FALLBACKS ---
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

# --- POSITION & REFERENCE GETTERS (Resolves overrides vs fallbacks) ---
func get_start_pos() -> Vector3:
	if start_marker:
		return start_marker.global_position
	return Vector3(start_x, 1.0, target_z)

func get_door_pos() -> Vector3:
	if door_marker:
		return door_marker.global_position
	return Vector3(door_x, 1.0, target_z)

func get_window_pos() -> Vector3:
	if window_marker:
		return window_marker.global_position
	return Vector3(0.0, 1.3, -1.54)

func get_jumpscare_pos() -> Vector3:
	if jumpscare_marker:
		return jumpscare_marker.global_position
	return get_door_pos()

func get_door_mesh() -> Node3D:
	if door_mesh_override:
		return door_mesh_override
	return door_mesh

func get_active_audio_player() -> AudioStreamPlayer3D:
	if custom_audio_player:
		return custom_audio_player
	return audio_player

func _ready():
	# Generate procedural sounds
	step_stream = _generate_clank_sound()
	screech_stream = _generate_screech_sound()
	rattle_stream = _generate_rattle_sound()
	
	audio_player.unit_size = 4.0
	audio_player.max_db = 3.0
	
	global_position = get_start_pos()

func _physics_process(delta):
	# Hunter is completely inactive on Day 1 no matter what
	if GameStats.current_day <= 1:
		global_position = get_start_pos()
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
			
	# Dynamically scale speed based on threat count and current day
	var day_factor = (GameStats.current_day - 1) * 0.25
	speed = (1.1 + day_factor) + danger_level * 0.45
	
	# Manage active timers
	if current_state == State.PATROLLING:
		next_investigation_time -= delta
		if next_investigation_time <= 3.0 and not warning_played:
			warning_played = true
			var ap = get_active_audio_player()
			ap.stream = screech_stream
			ap.pitch_scale = 0.75
			ap.play()
			
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

func handle_patrol(_delta):
	# Remain stationary at the starting point in the far corridor
	global_position = get_start_pos()
	
	# Check if it's time to investigate (approach)
	if next_investigation_time <= 0:
		start_approach()

func start_approach():
	current_state = State.APPROACHING
	warning_played = false

func handle_approaching(delta):
	# Move directly to the door dynamically in 3D
	var target = get_door_pos()
	if global_position.distance_to(target) > 0.15:
		global_position = global_position.move_toward(target, speed * 1.5 * delta)
	else:
		# Arrived at the door, randomly choose a peek location (DOOR, WINDOW, or CAMERA)
		var choices = [PeekLocation.DOOR]
		if window_peek_marker:
			choices.append(PeekLocation.WINDOW)
		if camera_peek_marker:
			choices.append(PeekLocation.CAMERA)
			
		active_peek_location = choices[randi() % choices.size()]
		
		# Warp to the chosen location
		if active_peek_location == PeekLocation.WINDOW:
			global_position = window_peek_marker.global_position
			look_at(Vector3(get_window_pos().x, global_position.y, get_window_pos().z))
		elif active_peek_location == PeekLocation.CAMERA:
			global_position = camera_peek_marker.global_position
			look_at(Vector3(get_door_pos().x, global_position.y, get_door_pos().z))
		else:
			global_position = get_door_pos()
			
		current_state = State.DOOR_RATTLE
		wait_at_door_timer = 2.0
		var ap = get_active_audio_player()
		if ap.stream != rattle_stream or not ap.playing:
			ap.stream = rattle_stream
			ap.play()

func handle_door_rattle(delta):
	# If player spots the Hunter on CCTV or through the window, it retreats!
	if check_if_player_sees_hunter():
		retreat_and_reset()
		return

	wait_at_door_timer -= delta
	if wait_at_door_timer <= 0:
		# Move back to door position to break in
		global_position = get_door_pos()
		
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
		var ap = get_active_audio_player()
		ap.stream = screech_stream
		ap.pitch_scale = randf_range(0.4, 0.6) # Low pitch thud/bang sound
		ap.play()
		
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
	var seen_on_cctv = false
	if player.current_state == player.State.COMPUTER_VIEW and game_3d.is_monitor_on:
		var cctv_win = get_tree().root.find_child("CCTVWindow", true, false)
		if cctv_win and cctv_win.visible:
			seen_on_cctv = true
			
	# 2. Check if player is looking directly at the glass window in 3D
	var seen_through_window = false
	if player.current_state != player.State.COMPUTER_VIEW:
		if not game_3d.is_curtain_closed:
			var camera = player.get_node_or_null("Camera3D")
			if camera:
				var window_pos = get_window_pos()
				var dir_to_window = (window_pos - camera.global_position).normalized()
				var camera_forward = -camera.global_transform.basis.z.normalized()
				var dot = camera_forward.dot(dir_to_window)
				if dot > 0.7:
					seen_through_window = true
					
	# Match based on chosen peek location
	if active_peek_location == PeekLocation.WINDOW:
		return seen_through_window
	elif active_peek_location == PeekLocation.CAMERA:
		return seen_on_cctv
	else:
		# DOOR can be spotted by either CCTV or direct window look (fallback)
		return seen_on_cctv or seen_through_window

func retreat_and_reset():
	current_state = State.PATROLLING
	global_position = get_start_pos()
	
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
	var ap = get_active_audio_player()
	ap.stream = step_stream
	ap.pitch_scale = 1.4
	ap.play()

func start_chase():
	# Slot machine threat trigger: immediately warp to the door and start rattling!
	if GameStats.current_day <= 1:
		return # Do nothing on Day 1
	current_state = State.APPROACHING
	is_active = true
	global_position = get_door_pos()

func kill_player():
	# Make sure sprite is visible
	$Sprite3D.visible = true
	
	# Warp to jumpscare position
	global_position = get_jumpscare_pos()
	
	# Rotate to face player directly during jumpscare
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
	
	# Play jumpscare sound
	var ap = get_active_audio_player()
	ap.stream = screech_stream
	ap.pitch_scale = 1.0
	ap.play()
	
	# Swing door open physically
	var dm = get_door_mesh()
	if dm:
		dm.rotation.y = deg_to_rad(90.0)
	
	# Trigger game over after brief freeze
	await get_tree().create_timer(1.2).timeout
	
	if dm:
		dm.rotation.y = 0.0
		
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
			var ap = get_active_audio_player()
			ap.stream = step_stream
			ap.pitch_scale = randf_range(0.85, 1.15)
			ap.play()

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
