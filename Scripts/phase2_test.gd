extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 2 (Door Rattle) start
	var hunter = get_node_or_null("HunterRobot")
	if hunter:
		hunter.is_active = true
		hunter.current_state = hunter.State.DOOR_RATTLE
		hunter.global_position.x = hunter.door_x
		hunter.wait_at_door_timer = 5.0 # Gives 5s to look/CCTV reset
		if hunter.audio_player:
			hunter.audio_player.stream = hunter.rattle_stream
			hunter.audio_player.play()
