extends "res://Scripts/johan_test.gd"

func _init():
	GameStats.current_day = 2

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Open curtain initially so monster at Phase1Spawn1 is visible through the window
	is_curtain_closed = false
	target_curtain_scale_x = 0.1
	target_curtain_pos_x = -0.75
	var curtain = get_node_or_null("Office/Curtain")
	if curtain:
		curtain.scale.x = 0.1
		curtain.position.x = -0.75
	
	# Find hunter and force Phase 1 (Perimeter Lurking) start instantly
	var hunter = get_node_or_null("HunterPhase1")
	if hunter:
		hunter.is_active = true
		hunter.spawn_and_stare()
