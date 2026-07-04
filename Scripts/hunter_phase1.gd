extends HunterBase
class_name HunterPhase1

@export_group("Phase 1 References")
@export var phase2_robot: CharacterBody3D
@export var phase3_robot: CharacterBody3D
@export var spawn_markers: Array = []

enum State {
	PATROLLING,
	SPAWNED
}

var current_state = State.PATROLLING
var next_investigation_time: float = 20.0 # Wait/cooldown timer before a spawn check is allowed
var warning_played: bool = false

# Timers for spawn/look mechanics
var stare_duration_timer: float = 0.0
var look_duration: float = 0.0

func _ready():
	super._ready()
	global_position = get_start_pos()
	$Sprite3D.visible = false
	current_state = State.PATROLLING
	is_active = false
	
	if not phase2_robot:
		phase2_robot = get_node_or_null("../HunterPhase2")
	if not phase3_robot:
		phase3_robot = get_node_or_null("../HunterPhase3")

func _physics_process(delta):
	# Hunter is completely inactive on Day 1 no matter what
	if GameStats.current_day <= 1:
		global_position = get_start_pos()
		current_state = State.PATROLLING
		$Sprite3D.visible = false
		is_active = false
		return

	# Setup activation on active days
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

	match current_state:
		State.PATROLLING:
			handle_patrol(delta)
		State.SPAWNED:
			handle_spawned(delta)

func handle_patrol(delta):
	$Sprite3D.visible = false
	global_position = get_start_pos()
	
	if next_investigation_time > 0:
		next_investigation_time -= delta
		if next_investigation_time <= 3.0 and not warning_played:
			warning_played = true
			var ap = get_active_audio_player()
			ap.stream = screech_stream
			ap.pitch_scale = 0.75
			ap.play()

func _input(event):
	# Spawn checks are only run if:
	# 1. We are actively patrolling/waiting in Phase 1
	# 2. The day is active (day 2+)
	# 3. The next_investigation_time cooldown has finished (<= 0)
	# 4. The player is at the computer (COMPUTER_VIEW)
	if current_state != State.PATROLLING or GameStats.current_day <= 1 or next_investigation_time > 0:
		return
		
	if not is_player_at_computer():
		return
		
	var is_click = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var is_enter = event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER)
	
	if is_click or is_enter:
		# Run spawn check with 3% base chance, scaled by danger level
		var danger_level = GameStats.let_through_bad_sprites.size()
		var spawn_chance = 0.03 + (danger_level * 0.015)
		if randf() < spawn_chance:
			spawn_and_stare()

func is_player_at_computer() -> bool:
	var game_3d = get_parent_node_3d()
	if not game_3d:
		return false
	var player = game_3d.get_node_or_null("Player")
	if player:
		return player.current_state == player.State.COMPUTER_VIEW
	return false

func spawn_and_stare():
	current_state = State.SPAWNED
	warning_played = false
			
	# Pick random spawn location
	var spawn_pos = get_start_pos()
	var spawn_idx = 0
	if spawn_markers.size() > 0:
		spawn_idx = randi() % spawn_markers.size()
		var marker_path = spawn_markers[spawn_idx]
		var marker = get_node_or_null(marker_path) as Marker3D
		if marker:
			spawn_pos = marker.global_position
	global_position = spawn_pos

	# Look at CCTV camera
	var cctv_camera = get_tree().root.find_child("CCTVCamera", true, false)
	if cctv_camera:
		look_at(Vector3(cctv_camera.global_position.x, global_position.y, cctv_camera.global_position.z))
	
	# Assign texture if loaded
	if GameStats.let_through_bad_sprites.size() > 0:
		$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
	$Sprite3D.visible = true
	
	# Cue Sound: Location-based or random selection
	var ap = get_active_audio_player()
	if spawn_idx == 2:
		# Rustling bushes (Garden entry)
		ap.stream = bush_rustle_stream
	else:
		# Concrete footsteps (Fence entry)
		ap.stream = concrete_step_stream
	ap.pitch_scale = randf_range(0.9, 1.1)
	ap.play()
	
	# Set duration to stare before advancing to Phase 2 (exactly 10 seconds)
	stare_duration_timer = 10.0
	look_duration = 0.0

func handle_spawned(delta):
	# Check if player sees the hunter (CCTV or 3D + flashlight)
	if check_if_player_sees_hunter():
		look_duration += delta
		if look_duration >= 1.0:
			disappear_and_reset()
			return
	else:
		# Reset continuous look requirement
		look_duration = 0.0

	var game_3d = get_parent_node_3d()
	var speed_mult = 1.0
	if game_3d and not game_3d.is_curtain_closed and game_3d.is_monitor_on:
		speed_mult = 2.0
		
	stare_duration_timer -= delta * speed_mult
	if stare_duration_timer <= 0:
		# Player ignored the robot. Advance to Phase 2!
		advance_to_phase2()

func check_if_player_sees_hunter() -> bool:
	# 1. Check if player looks at it on CCTV
	if check_if_player_looks_at_cctv():
		return true
		
	# 2. Check if player is looking directly at it in 3D and has flashlight on
	var game_3d = get_parent_node_3d()
	if not game_3d:
		return false
		
	var player = game_3d.get_node_or_null("Player")
	if not player:
		return false
		
	var seen_in_3d = false
	if player.current_state != player.State.COMPUTER_VIEW:
		var camera = player.get_node_or_null("Camera3D")
		if camera:
			var dir_to_hunter = (global_position - camera.global_position).normalized()
			var camera_forward = -camera.global_transform.basis.z.normalized()
			var dot = camera_forward.dot(dir_to_hunter)
			if dot > 0.7:
				# If monster is outside the window, curtain must be open
				var blocks_sight = false
				if global_position.z < -1.0 and game_3d.is_curtain_closed:
					blocks_sight = true
					
				if not blocks_sight:
					var flashlight_on = player.flashlight and player.flashlight.visible
					if flashlight_on:
						seen_in_3d = true
						
	return seen_in_3d

func check_if_player_looks_at_cctv() -> bool:
	var game_3d = get_parent_node_3d()
	if not game_3d:
		return false
		
	var player = game_3d.get_node_or_null("Player")
	if not player:
		return false
		
	if player.current_state == player.State.COMPUTER_VIEW and game_3d.is_monitor_on:
		var cctv_win = get_tree().root.find_child("CCTVWindow", true, false)
		if cctv_win and cctv_win.visible:
			return true
	return false

func disappear_and_reset():
	$Sprite3D.visible = false
	current_state = State.PATROLLING
	global_position = get_start_pos()
	
	# Random cooldown for next spawn check eligibility
	var danger_level = GameStats.let_through_bad_sprites.size()
	var freq_multiplier = max(0.35, 1.0 - (danger_level - 1) * 0.25)
	var day_multiplier = 1.0
	if GameStats.current_day == 2:
		day_multiplier = 0.75
	elif GameStats.current_day >= 3:
		day_multiplier = 0.5
	next_investigation_time = randf_range(40.0, 70.0) * freq_multiplier * day_multiplier
	warning_played = false
	
	# Play distant footstep sound moving away
	var ap = get_active_audio_player()
	ap.stream = step_stream
	ap.pitch_scale = 1.3
	ap.play()

func advance_to_phase2():
	$Sprite3D.visible = false
	current_state = State.PATROLLING
	global_position = get_start_pos()
	
	if phase2_robot:
		phase2_robot.activate()
		set_physics_process(false)

func retreat():
	# Called by subsequent phases when spotted
	set_physics_process(true)
	disappear_and_reset()

func start_chase():
	# Slot machine bypass: goes straight to Phase 3 (old Phase 2)!
	if GameStats.current_day <= 1:
		return
	$Sprite3D.visible = false
	current_state = State.PATROLLING
	global_position = get_start_pos()
	
	if phase3_robot:
		phase3_robot.activate(phase3_robot.PeekLocation.DOOR)
		set_physics_process(false)
