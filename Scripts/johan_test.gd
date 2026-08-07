extends "res://Scripts/game3d.gd"

func _ready():
	# Remove the original hunter robot to prevent it from interfering
	var old_hunter = get_node_or_null("HunterRobot")
	if old_hunter:
		old_hunter.free()
		
	# Hide the inspection robot sprite in the window
	var inspection_sprite = get_node_or_null("RobotChamber/RobotSprite3D")
	if inspection_sprite:
		inspection_sprite.visible = false
		
	super._ready()

	# Ensure the Hunter has a sprite texture to use
	if GameStats.let_through_bad_sprites.is_empty():
		var fallback_tex = load("res://Sprites/Robot1N.png")
		if fallback_tex:
			GameStats.let_through_bad_sprites.append(fallback_tex)

func _process(delta):
	super._process(delta)

func toggle_room2_lights():
	is_room2_light_on = not is_room2_light_on
	var light = get_node_or_null("Room2/CeilingLight2")
	if light:
		light.visible = is_room2_light_on

func toggle_room3_lights():
	is_room3_light_on = not is_room3_light_on
	var light = get_node_or_null("Room3/CeilingLight3")
	if light:
		light.visible = is_room3_light_on

func _on_robot_spawned(robot_data: RobotData):
	super._on_robot_spawned(robot_data)
	var inspection_sprite = get_node_or_null("RobotChamber/RobotSprite3D")
	if inspection_sprite:
		inspection_sprite.visible = false
