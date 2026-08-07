extends "res://Scripts/johan_test.gd"

func _init():
	GameStats.current_day = 2

func _ready():
	super._ready()
	GameStats.current_day = 2
	
	# Force player to sit at the computer first
	var player = get_tree().root.find_child("Player", true, false) if is_inside_tree() else null
	if player and player.has_method("interact_with_computer"):
		player.interact_with_computer()
		
	# Wait 1.0 second, then activate Hunter Phase 3 to test computer turn-off
	await get_tree().create_timer(1.0).timeout
	
	# Find hunter and force Phase 3 (Office Peeking / Door Rattle) start instantly
	var hunter = get_node_or_null("HunterPhase3")
	if hunter:
		hunter.activate(hunter.PeekLocation.DOOR)
		hunter.wait_at_door_timer = 5.0
