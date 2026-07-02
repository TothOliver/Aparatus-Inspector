extends HunterBase
class_name HunterPhase4

enum State {
	INACTIVE,
	BREAKING_IN
}

var current_state = State.INACTIVE
var bang_count: int = 0
var state_timer: float = 0.0

func _ready():
	super._ready()
	$Sprite3D.visible = false
	set_physics_process(false)

func activate():
	current_state = State.BREAKING_IN
	global_position = get_door_pos()
	
	# Face the office door
	look_at(Vector3(0.0, global_position.y, 0.5))
	
	if GameStats.let_through_bad_sprites.size() > 0:
		$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
		
	$Sprite3D.visible = true
	bang_count = 0
	state_timer = 1.0 # time until first bang thud
	set_physics_process(true)

func _physics_process(delta):
	if current_state != State.BREAKING_IN:
		return
		
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

func kill_player():
	current_state = State.INACTIVE
	set_physics_process(false)
	
	# Make sure sprite is visible
	$Sprite3D.visible = true
	if GameStats.let_through_bad_sprites.size() > 0:
		$Sprite3D.texture = GameStats.let_through_bad_sprites[0]
	
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
