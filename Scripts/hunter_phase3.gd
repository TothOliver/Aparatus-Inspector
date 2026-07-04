extends HunterBase
class_name HunterPhase3

@export_group("Phase 3 References")
@export var phase1_robot: CharacterBody3D
@export var phase4_robot: CharacterBody3D

enum PeekLocation {
	DOOR,
	WINDOW,
	CAMERA
}

enum State {
	INACTIVE,
	DOOR_RATTLE
}

var current_state = State.INACTIVE
var active_peek_location = PeekLocation.DOOR
var wait_at_door_timer: float = 0.0

func _ready():
	super._ready()
	$Sprite3D.visible = false
	set_physics_process(false)
	
	if not phase1_robot:
		phase1_robot = get_node_or_null("../HunterPhase1")
	if not phase4_robot:
		phase4_robot = get_node_or_null("../HunterPhase4")

func activate(peek_loc: PeekLocation):
	current_state = State.DOOR_RATTLE
	active_peek_location = peek_loc
	
	# Ensure texture is loaded
	if GameStats.let_through_bad_sprites.size() > 0:
		$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
	
	# Warp to the chosen location
	if active_peek_location == PeekLocation.WINDOW:
		global_position = window_peek_marker.global_position
		look_at(Vector3(get_window_pos().x, global_position.y, get_window_pos().z))
	elif active_peek_location == PeekLocation.CAMERA:
		global_position = camera_peek_marker.global_position
		look_at(Vector3(get_door_pos().x, global_position.y, get_door_pos().z))
	else:
		global_position = get_door_pos()
		# Face the office door
		look_at(Vector3(0.0, global_position.y, 0.5))
		
	$Sprite3D.visible = true
	wait_at_door_timer = 2.0
	
	var ap = get_active_audio_player()
	ap.stream = rattle_stream
	ap.pitch_scale = 1.0
	ap.play()
	
	set_physics_process(true)

func _physics_process(delta):
	if current_state != State.DOOR_RATTLE:
		return

	# If player spots the Hunter on CCTV or through the window, it retreats!
	if check_if_player_sees_hunter():
		retreat_and_reset()
		return

	wait_at_door_timer -= delta
	if wait_at_door_timer <= 0:
		# Deactivate and advance
		$Sprite3D.visible = false
		current_state = State.INACTIVE
		set_physics_process(false)
		
		print("[Phase 3 Debug] Timer expired! door_locked: ", GameStats.door_locked, " phase4_robot: ", phase4_robot)
		if GameStats.door_locked:
			if phase4_robot:
				phase4_robot.activate()
		else:
			if phase4_robot:
				phase4_robot.kill_player()

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
	var result = false
	if active_peek_location == PeekLocation.WINDOW:
		result = seen_through_window
	elif active_peek_location == PeekLocation.CAMERA:
		result = seen_on_cctv
	else:
		result = seen_on_cctv or seen_through_window
		
	print("[Phase 3 Debug] location: ", active_peek_location, " curtain_closed: ", game_3d.is_curtain_closed, " cctv: ", seen_on_cctv, " window: ", seen_through_window, " RETREAT: ", result)
	return result

func retreat_and_reset():
	$Sprite3D.visible = false
	current_state = State.INACTIVE
	set_physics_process(false)
	
	if phase1_robot:
		phase1_robot.retreat()
