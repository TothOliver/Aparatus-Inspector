extends "res://Scripts/game3d.gd"

func _ready():
	super._ready()
	GameStats.current_day = 2
	GameStats.door_locked = true # Lock door initially
	
	# Find hunter and force Phase 3 (Breaking In) start instantly
	var hunter = get_node_or_null("HunterPhase3")
	if hunter:
		hunter.activate()
		hunter.state_timer = 0.01 # Bangs instantly on load
