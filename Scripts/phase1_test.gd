extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 1 (Approaching) start instantly
	var hunter = get_node_or_null("HunterRobot")
	if hunter:
		hunter.is_active = true
		hunter.current_state = hunter.State.PATROLLING
		hunter.next_investigation_time = 0.01 # Begins approaching instantly
