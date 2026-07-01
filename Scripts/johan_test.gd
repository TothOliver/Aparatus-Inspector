extends "res://Scripts/game3d.gd"

func _ready():
	# Remove the original hunter robot to prevent it from interfering
	var old_hunter = get_node_or_null("HunterRobot")
	if old_hunter:
		old_hunter.free()
	super._ready()
