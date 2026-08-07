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
var is_flashed: bool = false
var flash_retreat_timer: float = 0.0

func _ready():
	super._ready()
	set_monster_visible(false)
	set_physics_process(false)
	
	if not phase1_robot:
		phase1_robot = get_node_or_null("../HunterPhase1")
	if not phase3_robot:
		phase3_robot = get_node_or_null("../HunterPhase3")

func get_all_spawn_markers() -> Array[Marker3D]:
	var markers: Array[Marker3D] = []
	for marker_path in phase2_spawn_markers:
		var m = get_node_or_null(marker_path) as Marker3D
		if m:
			markers.append(m)
			
	if markers.is_empty() and get_parent():
		for child in get_parent().get_children():
			if child is Marker3D and child.name.begins_with("Phase2Spawn"):
				markers.append(child as Marker3D)
				
	return markers

func activate(is_door_retreat: bool = false):
	current_state = State.SPAWNED
	is_flashed = false
	flash_retreat_timer = 0.0
	
	# Duration to stare before advancing (longer if retreating from door to prevent instant respawn)
	# Done first to prevent immediate transition to Phase 3 due to async footprint awaits
	if is_door_retreat:
		stare_duration_timer = randf_range(30.0, 50.0)
	else:
		stare_duration_timer = 20.0
	
	# Pick random closer spawn location
	var markers = get_all_spawn_markers()
	var spawn_pos = get_start_pos()
	if not markers.is_empty():
		var marker = markers[randi() % markers.size()]
		spawn_pos = marker.global_position
	global_position = spawn_pos
	
	# Ensure texture is loaded
	var sprite = get_node_or_null("Sprite3D") as Sprite3D
	if sprite and GameStats.let_through_bad_sprites.size() > 0:
		sprite.texture = GameStats.let_through_bad_sprites[0]
	set_monster_visible(true)
	look_at_closest_camera()
	
	# Play heavy heavy concrete step sound to show it moved closer (4 steps in sequence)
	for i in range(4):
		if is_inside_tree() and current_state == State.SPAWNED:
			if SoundManager:
				SoundManager.play_sound_3d("monster_footstep", global_position, +4.0)
				SoundManager.play_sound("monster_footstep", -2.0) # 2D helper
			else:
				var ap = get_active_audio_player()
				if ap:
					ap.stream = concrete_step_stream
					ap.pitch_scale = randf_range(0.7, 0.9)
					ap.play()
			await get_tree().create_timer(0.5).timeout
	
	set_physics_process(true)

func _physics_process(delta):
	if current_state != State.SPAWNED:
		return

	# Once flashed (spotted via 3D flashlight), start 1-second retreat countdown
	if not is_flashed:
		if check_if_player_sees_hunter():
			is_flashed = true
			flash_retreat_timer = 1.0
	else:
		flash_retreat_timer -= delta
		if flash_retreat_timer <= 0:
			retreat_and_reset()
			return

	var game_3d = get_parent_node_3d()
	var speed_mult = 1.0
	if game_3d and not game_3d.is_curtain_closed and game_3d.is_monitor_on:
		speed_mult = 2.0
		
	stare_duration_timer -= delta * speed_mult
	if stare_duration_timer <= 0:
		advance_to_phase3()

func check_if_player_sees_hunter() -> bool:
	# 1. Check if player looks at it on CCTV with camera flashlight ON
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
				var blocks_sight = false
				if global_position.z < -1.0:
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
		
	if not GameStats.cctv_light_on:
		return false
		
	if player.current_state == player.State.COMPUTER_VIEW and game_3d.is_monitor_on:
		var cctv_win = get_tree().root.find_child("CCTVWindow", true, false)
		if cctv_win and cctv_win.visible:
			var vp = game_3d.get_node_or_null("CCTVViewport")
			if vp:
				for cam in vp.get_children():
					if cam is Camera3D and cam.current:
						if global_position.distance_to(cam.global_position) < 12.0:
							return true
	return false

func retreat_and_reset():
	is_flashed = false
	flash_retreat_timer = 0.0
	set_monster_visible(false)
	current_state = State.INACTIVE
	set_physics_process(false)
	
	if phase1_robot:
		phase1_robot.retreat()

func advance_to_phase3():
	set_monster_visible(false)
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
