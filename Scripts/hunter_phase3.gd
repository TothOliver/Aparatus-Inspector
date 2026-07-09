extends HunterBase
class_name HunterPhase3

@export_group("Phase 3 References")
@export var phase1_robot: CharacterBody3D
@export var phase2_robot: CharacterBody3D
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
	if not phase2_robot:
		phase2_robot = get_node_or_null("../HunterPhase2")
	if not phase4_robot:
		phase4_robot = get_node_or_null("../HunterPhase4")

func activate(_peek_loc: PeekLocation):
	current_state = State.DOOR_RATTLE
	active_peek_location = PeekLocation.DOOR
	
	# Ensure texture is loaded
	if GameStats.let_through_bad_sprites.size() > 0:
		$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
	
	global_position = get_door_pos()
	# Face the office door
	look_at(Vector3(0.0, global_position.y, 0.5))
		
	$Sprite3D.visible = true
	wait_at_door_timer = 6.0
	
	var ap = get_active_audio_player()
	ap.stream = rattle_stream
	ap.pitch_scale = 1.0
	ap.play()
	
	set_physics_process(true)
 
func _physics_process(delta):
	if current_state != State.DOOR_RATTLE:
		return
 
	wait_at_door_timer -= delta
	if wait_at_door_timer <= 0:
		# Deactivate and advance
		$Sprite3D.visible = false
		current_state = State.INACTIVE
		set_physics_process(false)
		
		print("[Phase 3 Debug] Timer expired! door_locked: ", GameStats.door_locked, " phase2_robot: ", phase2_robot)
		if GameStats.door_locked:
			if phase2_robot:
				phase2_robot.activate(true)
		else:
			if phase4_robot:
				phase4_robot.kill_player()
 
func check_if_player_sees_hunter() -> bool:
	return false

func retreat_and_reset():
	$Sprite3D.visible = false
	current_state = State.INACTIVE
	set_physics_process(false)
	
	if phase1_robot:
		phase1_robot.retreat()
