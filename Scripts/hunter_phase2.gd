extends HunterBase
class_name HunterPhase2

@export_group("Phase 2 References")
@export var phase1_robot: CharacterBody3D
@export var phase3_robot: CharacterBody3D
@export var phase2_spawn_markers: Array = []

enum State {
	INACTIVE,
	SPAWNED
}

var current_state = State.INACTIVE
var stare_duration_timer: float = 0.0
var look_duration: float = 0.0

func _ready():
	super._ready()
	$Sprite3D.visible = false
	set_physics_process(false)
	
	if not phase1_robot:
		phase1_robot = get_node_or_null("../HunterPhase1")
	if not phase3_robot:
		phase3_robot = get_node_or_null("../HunterPhase3")

func activate():
	current_state = State.SPAWNED
	look_duration = 0.0
	
	# Pick random closer spawn location
	var spawn_pos = get_start_pos()
	if phase2_spawn_markers.size() > 0:
		var marker_path = phase2_spawn_markers[randi() % phase2_spawn_markers.size()]
		var marker = get_node_or_null(marker_path) as Marker3D
		if marker:
			spawn_pos = marker.global_position
	global_position = spawn_pos
	
	# Look towards the office center
	look_at(Vector3(0.0, global_position.y, 0.5))
	
	# Ensure texture is loaded
	if GameStats.let_through_bad_sprites.size() > 0:
		$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
	$Sprite3D.visible = true
	
	# Play heavy heavy concrete step sound to show it moved closer
	var ap = get_active_audio_player()
	ap.stream = concrete_step_stream
	ap.pitch_scale = randf_range(0.7, 0.9)
	ap.play()
	
	# Duration to stare before advancing (exactly 10 seconds)
	stare_duration_timer = 10.0
	
	set_physics_process(true)

func _physics_process(delta):
	if current_state != State.SPAWNED:
		return

	# Check if player looks directly at the hunter
	if check_if_player_sees_hunter():
		look_duration += delta
		if look_duration >= 1.0:
			retreat_and_reset()
			return
	else:
		look_duration = 0.0

	var game_3d = get_parent_node_3d()
	var speed_mult = 1.0
	if game_3d and not game_3d.is_curtain_closed and game_3d.is_monitor_on:
		speed_mult = 2.0
		
	stare_duration_timer -= delta * speed_mult
	if stare_duration_timer <= 0:
		advance_to_phase3()

func check_if_player_sees_hunter() -> bool:
	var game_3d = get_parent_node_3d()
	if not game_3d:
		return false
		
	var player = game_3d.get_node_or_null("Player")
	if not player:
		return false
		
	# Check if player is looking directly at the hunter in 3D and has flashlight on
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

func retreat_and_reset():
	$Sprite3D.visible = false
	current_state = State.INACTIVE
	set_physics_process(false)
	
	if phase1_robot:
		phase1_robot.retreat()

func advance_to_phase3():
	$Sprite3D.visible = false
	current_state = State.INACTIVE
	set_physics_process(false)
	
	if phase3_robot:
		# Pick random peek location for Phase 3 (old Phase 2)
		var choices = [phase3_robot.PeekLocation.DOOR]
		if window_peek_marker:
			choices.append(phase3_robot.PeekLocation.WINDOW)
		if camera_peek_marker:
			choices.append(phase3_robot.PeekLocation.CAMERA)
		var chosen_loc = choices[randi() % choices.size()]
		
		phase3_robot.activate(chosen_loc)
