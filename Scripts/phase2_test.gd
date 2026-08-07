extends "res://Scripts/johan_test.gd"

func _init():
	GameStats.current_day = 2

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 2 (Moves Closer) start instantly
	var hunter = get_node_or_null("HunterPhase2")
	if hunter:
		hunter.activate()
		hunter.stare_duration_timer = 10.0
