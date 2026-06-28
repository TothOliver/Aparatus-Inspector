extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	GameStats.door_locked = true # Ensure door is locked initially
	
	# Find hunter and force Phase 3 (Breaking In) start
	var hunter = get_node_or_null("HunterRobot")
	if hunter:
		hunter.is_active = true
		hunter.current_state = hunter.State.BREAKING_IN
		hunter.global_position.x = hunter.door_x
		hunter.bang_count = 0
		hunter.state_timer = 2.0 # 2s until first bang
