extends "res://Scripts/johan_test.gd"

func _init():
	GameStats.current_day = 2

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 3 (Office Peeking / Door Rattle) start instantly
	var hunter = get_node_or_null("HunterPhase3")
	if hunter:
		hunter.activate(hunter.PeekLocation.DOOR)
		hunter.wait_at_door_timer = 5.0
