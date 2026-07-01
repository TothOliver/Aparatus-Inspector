extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Find hunter and force Phase 1 (Perimeter Lurking) start instantly
	var hunter = get_node_or_null("HunterPhase1")
	if hunter:
		hunter.is_active = true
		hunter.spawn_and_stare()
