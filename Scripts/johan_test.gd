extends "res://Scripts/game3d.gd"

var is_curtain2_closed: bool = false
var target_curtain2_scale_x: float = 0.1
var target_curtain2_pos_x: float = 5.25 # Open is 5.25, closed is 6.0

var is_curtain3_closed: bool = false
var target_curtain3_scale_x: float = 0.1
var target_curtain3_pos_x: float = -0.75 # Open is -0.75, closed is 0.0

var is_room2_light_on: bool = true
var is_room3_light_on: bool = true

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
		var fallback_tex = load("res://Sprites/robot1.png")
		if fallback_tex:
			GameStats.let_through_bad_sprites.append(fallback_tex)
			
	# Close the office curtain initially so the player doesn't instantly spot the Hunter on spawn
	is_curtain_closed = true
	target_curtain_scale_x = 1.0
	target_curtain_pos_x = 0.0

func _process(delta):
	super._process(delta)
	
	# Interpolate Curtain 2 scale and position
	var curtain2 = get_node_or_null("Office/Curtain2")
	if curtain2:
		curtain2.scale.x = lerp(curtain2.scale.x, target_curtain2_scale_x, 8.0 * delta)
		curtain2.position.x = lerp(curtain2.position.x, target_curtain2_pos_x, 8.0 * delta)

	# Interpolate Curtain 3 scale and position
	var curtain3 = get_node_or_null("Office/Curtain3")
	if curtain3:
		curtain3.scale.x = lerp(curtain3.scale.x, target_curtain3_scale_x, 8.0 * delta)
		curtain3.position.x = lerp(curtain3.position.x, target_curtain3_pos_x, 8.0 * delta)

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

func toggle_curtain2():
	is_curtain2_closed = not is_curtain2_closed
	if is_curtain2_closed:
		target_curtain2_scale_x = 1.0
		target_curtain2_pos_x = 6.0
	else:
		target_curtain2_scale_x = 0.1
		target_curtain2_pos_x = 5.25

func toggle_curtain3():
	is_curtain3_closed = not is_curtain3_closed
	if is_curtain3_closed:
		target_curtain3_scale_x = 1.0
		target_curtain3_pos_x = 0.0
	else:
		target_curtain3_scale_x = 0.1
		target_curtain3_pos_x = -0.75

func _on_robot_spawned(robot_data: RobotData):
	super._on_robot_spawned(robot_data)
	var inspection_sprite = get_node_or_null("RobotChamber/RobotSprite3D")
	if inspection_sprite:
		inspection_sprite.visible = false
