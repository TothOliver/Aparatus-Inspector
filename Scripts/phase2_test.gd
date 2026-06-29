extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 2 (Door Rattle) start instantly
	var hunter = get_node_or_null("HunterRobot")
	if hunter:
		hunter.is_active = true
		hunter.current_state = hunter.State.DOOR_RATTLE
		hunter.active_peek_location = hunter.PeekLocation.DOOR # Tests both camera and window sight vectors
		hunter.global_position = hunter.get_door_pos()
		hunter.wait_at_door_timer = 5.0
		var ap = hunter.get_active_audio_player()
		if ap:
			ap.stream = hunter.rattle_stream
			ap.play()
