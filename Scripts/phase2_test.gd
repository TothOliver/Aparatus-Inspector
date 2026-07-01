extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 2 (Door Rattle) start instantly
	var hunter = get_node_or_null("HunterPhase2")
	if hunter:
		hunter.activate(hunter.PeekLocation.DOOR)
		hunter.wait_at_door_timer = 5.0
