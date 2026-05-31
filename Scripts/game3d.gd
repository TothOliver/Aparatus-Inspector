extends Node3D

@onready var sprite_3d = $RobotChamber/RobotSprite3D
@onready var viewport_container = $SubViewportContainer
@onready var sub_viewport = $SubViewportContainer/SubViewport
@onready var game_2d = $SubViewportContainer/SubViewport/Control2

@onready var desk_light = $Lighting/DeskLight
@onready var screen_mesh = $ComputerMonitor/Screen
@onready var corridor_light = $Lighting/CorridorLight
@onready var door_light = $Office/DoorLight
@onready var reticle = $HUD/Reticle

# Office States (monitored by roaming hunter AI)
var is_ceiling_light_on: bool = true
var is_monitor_on: bool = true

# Tracks if power has completely failed
var is_blackout: bool = false

func _ready():
	# Configure mouse mode initially
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Connect to the 2D game's robot spawning signal
	if game_2d:
		game_2d.robot_spawned.connect(_on_robot_spawned)
		if game_2d.current_robot:
			_on_robot_spawned(game_2d.current_robot)
	
	if viewport_container:
		viewport_container.visible = false
		
	var player = $Player
	if player:
		player.interact_prompt_changed.connect(_on_interact_prompt_changed)
		
	# Initialize door light to green
	_update_door_light_material(false)

func _process(delta):
	# Power grid calculations
	if GameStats.door_locked:
		var drain_rate = 3.5 * (1.0 + (GameStats.current_day - 1) * 0.45)
		GameStats.power_level = max(0.0, GameStats.power_level - drain_rate * delta)
		if GameStats.power_level <= 0.0:
			GameStats.door_locked = false
			_trigger_power_outage()
	else:
		if GameStats.power_level < 100.0:
			# Recharge power: ~2.5% per second
			GameStats.power_level = min(100.0, GameStats.power_level + 2.5 * delta)
			if is_blackout and GameStats.power_level >= 10.0:
				_restore_power()

	# Creepy flickering corridor light effect
	if corridor_light and randf() < 0.08:
		corridor_light.light_energy = randf_range(0.15, 0.75)
		
	# Update door light mesh material based on global lock state
	_update_door_light_material(GameStats.door_locked)

func _input(event):
	# Forward all keyboard events to SubViewport so typing in the Terminal/Notepad works
	if viewport_container and viewport_container.visible:
		if event is InputEventKey:
			sub_viewport.push_input(event)
			if event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
				var desktop = sub_viewport.get_node_or_null("Control2/DesktopOS")
				if desktop and "active_window" in desktop and desktop.active_window and desktop.active_window.name == "TerminalWindow":
					_double_trigger_enter.call_deferred()

func enter_computer_view():
	if not is_monitor_on or is_blackout:
		return # Cannot view a dead monitor
		
	# Release mouse and show 2D GUI overlay on screen
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if viewport_container:
		viewport_container.visible = true
	if reticle:
		reticle.visible = false

func exit_computer_view():
	# Re-lock mouse and hide 2D overlay
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if viewport_container:
		viewport_container.visible = false
	if reticle:
		reticle.visible = true

func _on_robot_spawned(robot_data: RobotData):
	if sprite_3d and robot_data and robot_data.sprite:
		sprite_3d.texture = robot_data.sprite

# Light controls (can be called by light switches or the MS-DOS terminal)
func toggle_ceiling_lights():
	if is_blackout:
		return
	is_ceiling_light_on = not is_ceiling_light_on
	_update_lights_visibility()

func toggle_monitor_power():
	if is_blackout:
		return
	is_monitor_on = not is_monitor_on
	if screen_mesh:
		screen_mesh.visible = is_monitor_on
		
	# If monitor is turned off, force player out of screen focus mode
	var player = $Player
	if not is_monitor_on and player and player.current_state == player.State.COMPUTER_VIEW:
		player.exit_computer_view()

func _update_lights_visibility():
	if desk_light:
		desk_light.visible = is_ceiling_light_on and not is_blackout
	var ambient_light = $Lighting/AmbientLight
	if ambient_light:
		ambient_light.visible = is_ceiling_light_on and not is_blackout

func _trigger_power_outage():
	is_blackout = true
	
	# Turn off monitor and lights visually
	if screen_mesh:
		screen_mesh.visible = false
		
	if desk_light:
		desk_light.visible = false
		
	var ambient_light = $Lighting/AmbientLight
	if ambient_light:
		ambient_light.visible = false
		
	# Force player out of computer screen
	var player = $Player
	if player and player.current_state == player.State.COMPUTER_VIEW:
		player.exit_computer_view()

func _restore_power():
	is_blackout = false
	# Restore screen and lights to their previous settings
	if screen_mesh:
		screen_mesh.visible = is_monitor_on
	_update_lights_visibility()

func _update_door_light_material(locked: bool):
	if door_light:
		var mat = door_light.get_active_material(0) as StandardMaterial3D
		if mat:
			if is_blackout:
				mat.albedo_color = Color(0.1, 0.1, 0.1) # black/off
				mat.emission = Color(0, 0, 0)
			elif locked:
				mat.albedo_color = Color(1, 0, 0) # red
				mat.emission = Color(1, 0, 0)
			else:
				mat.albedo_color = Color(0, 1, 0) # green
				mat.emission = Color(0, 1, 0)

func _on_interact_prompt_changed(text: String):
	$HUD/PromptLabel.text = text

func _double_trigger_enter():
	# Wait a tiny bit to let the first submission finish executing
	await get_tree().create_timer(0.04).timeout
	if viewport_container and viewport_container.visible:
		# Create simulated Enter pressed event
		var press_event = InputEventKey.new()
		press_event.pressed = true
		press_event.keycode = KEY_ENTER
		press_event.physical_keycode = KEY_ENTER
		sub_viewport.push_input(press_event)
		
		# Create simulated Enter released event
		var release_event = InputEventKey.new()
		release_event.pressed = false
		release_event.keycode = KEY_ENTER
		release_event.physical_keycode = KEY_ENTER
		sub_viewport.push_input(release_event)
