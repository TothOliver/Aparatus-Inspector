extends CharacterBody3D
class_name HunterRobot

@onready var audio_player = $AudioStreamPlayer3D
@onready var door_mesh = $"../Office/LeftDoor" # Target door mesh to rotate

enum State {
	PATROLLING,
	INVESTIGATING,
	CHASING,
	ATTACKING
}

var current_state = State.PATROLLING
var patrol_dir: int = 1
var speed: float = 1.2
var chase_speed: float = 3.5

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

# Procedural audio assets
var step_stream: AudioStreamWAV
var screech_stream: AudioStreamWAV
var rattle_stream: AudioStreamWAV

# Logic timers
var next_investigation_time: float = 20.0 # Starts first patrol
var is_door_open: bool = false
var is_active: bool = false
var patrol_laps: int = 0
var is_returning_from_investigation: bool = false
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
	var danger_level = GameStats.let_through_bad_sprites.size()
	
	# Manage visibility: hide when idle/resting at start_x
	var is_idle = (danger_level == 0) or (current_state == State.PATROLLING and patrol_laps >= 4)
	$Sprite3D.visible = not is_idle
	
	if danger_level == 0:
		global_position = Vector3(start_x, 1.0, target_z)
		return # Threat level is 0, stay passive in the background
		
	# Activate robot on first threat
	if not is_active:
		is_active = true
		var day_multiplier = 1.0
		if GameStats.current_day == 2:
			day_multiplier = 0.75
		elif GameStats.current_day == 3:
			day_multiplier = 0.5
		next_investigation_time = randf_range(30.0, 60.0) * day_multiplier
		warning_played = false
		if GameStats.let_through_bad_sprites.size() > 0:
			$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
			
	# Dynamically scale speeds based on threat count and current day
	var day_factor = (GameStats.current_day - 1) * 0.25
	speed = (1.1 + day_factor) + danger_level * 0.45
	chase_speed = (4.2 + day_factor * 1.5) + danger_level * 0.65
	
	# Manage state timer
	state_timer -= delta
	next_investigation_time -= delta
	
	if next_investigation_time <= 3.0 and not warning_played and is_active:
		warning_played = true
		audio_player.stream = screech_stream
		audio_player.pitch_scale = 0.75
		audio_player.play()
	
	match current_state:
		State.PATROLLING:
			handle_patrol(delta)
		State.INVESTIGATING:
			handle_investigation(delta)
		State.CHASING:
			handle_chase(delta)
		State.ATTACKING:
			# Jumpscare in progress
			pass

	# Handle footstep audio timing
	handle_footsteps(delta)

func handle_patrol(delta):
	if patrol_laps >= 4:
		# Stay idle at starting position
		global_position.x = start_x
		global_position.z = target_z
		return

	# Move back and forth in corridor
	global_position.x += patrol_dir * speed * delta
	global_position.z = target_z
	
	# Clamp patrol bounds
	if global_position.x < start_x:
		global_position.x = start_x
		patrol_dir = 1
		patrol_laps += 1
	elif global_position.x > door_x - 1.0:
		global_position.x = door_x - 1.0
		patrol_dir = -1
		patrol_laps += 1
		
	# Check if it's time to investigate
	if next_investigation_time <= 0:
		current_state = State.INVESTIGATING
		is_returning_from_investigation = false
		state_timer = 13.0 # investigation phase length (was 8.0)
		var danger_level = GameStats.let_through_bad_sprites.size()
		var freq_multiplier = max(0.35, 1.0 - (danger_level - 1) * 0.25)
		var day_multiplier = 1.0
		if GameStats.current_day == 2:
			day_multiplier = 0.75
		elif GameStats.current_day == 3:
			day_multiplier = 0.5
		next_investigation_time = randf_range(40.0, 70.0) * freq_multiplier * day_multiplier
		warning_played = false

func handle_investigation(delta):
	# Move directly to the door
	if global_position.x < door_x:
		global_position.x = move_toward(global_position.x, door_x, speed * 1.5 * delta)
		state_timer = 13.0 # Keep timer held at 13.0 until we arrive at the door
		return
		
	# Once at the door, rattle it immediately for the first 1.2 seconds
	if state_timer > 11.8:
		if audio_player.stream != rattle_stream or not audio_player.playing:
			audio_player.stream = rattle_stream
			audio_player.play()
			
	# If the door is locked, the robot bangs on the door and cannot enter
	if GameStats.door_locked:
		if state_timer <= 11.8 and state_timer > 1.5:
			if not audio_player.playing or audio_player.stream != screech_stream:
				audio_player.stream = screech_stream
				audio_player.pitch_scale = randf_range(0.4, 0.6) # Low pitch thud/bang sound
				audio_player.play()
		if state_timer <= 0:
			current_state = State.PATROLLING
			patrol_dir = -1
			patrol_laps = 3 # 1 return walk to start_x then idle
		return
			
	# If unlocked, perform room search
	if state_timer <= 11.8:
		# Open the door physically
		if door_mesh:
			door_mesh.rotation.y = lerp_angle(door_mesh.rotation.y, deg_to_rad(90.0), 5.0 * delta)
			
		var center_target = Vector3(-0.5, 1.0, 1.5)
		var exit_target = Vector3(door_x, 1.0, target_z)
		
		if not is_returning_from_investigation:
			# Enter the middle of the main room
			global_position = global_position.move_toward(center_target, speed * delta)
			
			# Check if reached center of the room
			if global_position.distance_to(center_target) < 0.2:
				var game_3d = get_parent_node_3d()
				var is_safe = false
				if game_3d:
					var player = game_3d.get_node_or_null("Player")
					var room_has_light = game_3d.is_ceiling_light_on and not game_3d.is_blackout
					var is_crouching = player.get("is_crouching") if (player and "is_crouching" in player) else false
					if not room_has_light and is_crouching:
						is_safe = true
						
				if is_safe:
					is_returning_from_investigation = true
				else:
					start_chase()
					return
		else:
			# Go back to exit
			global_position = global_position.move_toward(exit_target, speed * delta)
			
			# Close the door as we walk back out
			if door_mesh and global_position.distance_to(exit_target) < 1.0:
				door_mesh.rotation.y = lerp_angle(door_mesh.rotation.y, 0.0, 5.0 * delta)
				
			# If reached corridor doorway, transition back to patrol
			if global_position.distance_to(exit_target) < 0.2:
				if door_mesh:
					door_mesh.rotation.y = 0.0
				current_state = State.PATROLLING
				patrol_dir = -1
				patrol_laps = 3 # 1 return walk to start_x then idle

func start_chase():
	current_state = State.CHASING
	audio_player.stream = screech_stream
	audio_player.pitch_scale = 1.0
	audio_player.play()
	
	# Open the door physically by rotating it
	if door_mesh:
		door_mesh.rotation.y = deg_to_rad(90.0)
		is_door_open = true

func handle_chase(delta):
	# Find player
	var target = player_office_pos
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		target = player.global_position
		target.y = global_position.y
		
	# Move through the door and chase player in office
	if global_position.x > door_x:
		global_position = global_position.move_toward(target, chase_speed * delta)
	else:
		# If the robot is still in the corridor (X <= door_x), move in X direction first to enter room
		global_position.x = move_toward(global_position.x, door_x + 0.5, chase_speed * delta)
		
	# Check distance to player (XZ 2D distance to avoid vertical Y pivot offset issues)
	if player:
		var robot_pos_2d = Vector2(global_position.x, global_position.z)
		var player_pos_2d = Vector2(player.global_position.x, player.global_position.z)
		if robot_pos_2d.distance_to(player_pos_2d) < 0.9:
			kill_player()

func kill_player():
	current_state = State.ATTACKING
	# Play screaming sound
	audio_player.stream = screech_stream
	audio_player.pitch_scale = 1.0
	audio_player.play()
	
	# Trigger game over after brief freeze
	await get_tree().create_timer(1.2).timeout
	
	# Close door back
	if door_mesh:
		door_mesh.rotation.y = 0.0
		
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")

func is_player_detectable() -> bool:
	var game_3d = get_parent_node_3d()
	if not game_3d:
		return true
		
	var player = game_3d.get_node_or_null("Player")
	if not player:
		return true
		
	var is_crouching = player.get("is_crouching") if "is_crouching" in player else false
	var ceiling_light_on = game_3d.is_ceiling_light_on
	var monitor_glowing = game_3d.is_monitor_on and player.current_state != player.State.WALKING
	
	if is_crouching:
		# Crouching under the desk is safe if the ceiling lights are off (monitor can stay on)
		return ceiling_light_on
	else:
		# Not crouching: detectable if ceiling light is on or monitor is glowing
		return ceiling_light_on or monitor_glowing

func handle_footsteps(delta):
	if current_state == State.ATTACKING:
		return
		
	footstep_timer -= delta
	if footstep_timer <= 0:
		# Set delay based on state and danger level
		var danger_level = GameStats.let_through_bad_sprites.size()
		var step_multiplier = max(0.5, 1.0 - (danger_level - 1) * 0.15)
		footstep_delay = 0.5 * step_multiplier if current_state == State.CHASING else 0.95 * step_multiplier
		footstep_timer = footstep_delay
		
		# Play step sound if moving in chasing, patrolling, or investigating (unless standing still)
		var is_moving = true
		if current_state == State.INVESTIGATING:
			if GameStats.door_locked and global_position.x >= door_x - 0.1:
				is_moving = false
		elif current_state == State.PATROLLING:
			if patrol_laps >= 4:
				is_moving = false
				
		if (current_state == State.CHASING or current_state == State.PATROLLING or current_state == State.INVESTIGATING) and is_moving:
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
		# Metallic overlay wave
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
		# Frequency modulation for siren/screech
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
	
	# Generate a rattling series of short clicks
	for i in range(num_samples):
		var t = float(i) / 11025.0
		# Rapid envelope peaks
		var rattle_env = abs(sin(2.0 * PI * 18.0 * t))
		var env = exp(-35.0 * fmod(t, 0.05)) * rattle_env
		var val = (randf() - 0.5) * 0.8
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream
