extends Node3D

@onready var sprite_3d = $RobotChamber/RobotSprite3D
@onready var viewport_container = $SubViewportContainer
@onready var sub_viewport = $SubViewportContainer/SubViewport
@onready var game_2d = $SubViewportContainer/SubViewport/Control2

@onready var desk_light = $Lighting/DeskLight
@export var screen_mesh: MeshInstance3D
@onready var corridor_light = $Lighting/CorridorLight
@onready var door_light = $Office/DoorLight
@onready var door_mesh = $Office/LeftDoor
@onready var reticle = $HUD/Reticle
@onready var ceiling_bulb = $Office/CeilingFixture/Bulb
@export var wifi_led: MeshInstance3D
@onready var curtain_node = $Office/Curtain

var aspect_overlay: Control
var left_bar: ColorRect
var right_bar: ColorRect

var os_mask_overlay: Control
var os_left_mask: ColorRect
var os_right_mask: ColorRect

var is_curtain2_closed: bool = false
var target_curtain2_scale_x: float = 0.1
var target_curtain2_pos_x: float = 5.25 # Open is 5.25, closed is 6.0

var is_curtain3_closed: bool = false
var target_curtain3_scale_x: float = 0.1
var target_curtain3_pos_x: float = -0.75 # Open is -0.75, closed is 0.0

var is_room2_light_on: bool = true
var is_room3_light_on: bool = true

# Office States (monitored by roaming hunter AI)
var is_ceiling_light_on: bool = true
var is_monitor_on: bool = true

# Curtain states
var is_curtain_closed: bool = false
var target_curtain_scale_x: float = 0.1
var target_curtain_pos_x: float = -0.75

# Tracks if power has completely failed
var is_blackout: bool = false

# Outage / Circuit Breaker variables
var outage_timer: float = 0.0
var is_breaker_tripped: bool = false
@onready var breaker_lever = get_node_or_null("Office/BreakerBox/BreakerLever") as MeshInstance3D

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if sprite_3d:
		sprite_3d.visible = false
	if not screen_mesh:
		screen_mesh = get_node_or_null("Office/DeskSetup/placeholder/ComputerMonitor/Screen") as MeshInstance3D
	if not screen_mesh:
		screen_mesh = get_node_or_null("ComputerMonitor/Screen") as MeshInstance3D
		
	if not wifi_led:
		wifi_led = get_node_or_null("Office/DeskSetup/placeholder/WifiRouter/WifiButton") as MeshInstance3D
	if not wifi_led:
		wifi_led = get_node_or_null("Office/WifiRouter/WifiButton") as MeshInstance3D
		
	if screen_mesh and sub_viewport:
		var material = screen_mesh.get_active_material(0) as StandardMaterial3D
		if not material:
			material = screen_mesh.get_surface_override_material(0) as StandardMaterial3D
		if not material and screen_mesh.mesh:
			material = screen_mesh.mesh.material as StandardMaterial3D
		if material:
			material.albedo_texture = sub_viewport.get_texture()
		
	# Configure mouse mode initially
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Initialize first outage timer randomly between 135.0 and 270.0 seconds (3x the original 45.0 - 90.0 range)
	outage_timer = randf_range(135.0, 270.0)
			
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
	_update_wifi_led_material()
	_update_lights_visibility()

	if has_node("/root/BGMusic"):
		var bg_music = get_node("/root/BGMusic")
		if bg_music is AudioStreamPlayer and not bg_music.playing:
			bg_music.play()

	# Create 16:9 aspect ratio overlay for first person view
	aspect_overlay = Control.new()
	aspect_overlay.name = "Aspect169Overlay"
	aspect_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	aspect_overlay.anchor_left = 0
	aspect_overlay.anchor_top = 0
	aspect_overlay.anchor_right = 1
	aspect_overlay.anchor_bottom = 1
	aspect_overlay.offset_left = 0
	aspect_overlay.offset_top = 0
	aspect_overlay.offset_right = 0
	aspect_overlay.offset_bottom = 0
	aspect_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	left_bar = ColorRect.new()
	left_bar.name = "LeftBar"
	left_bar.color = Color(0, 0, 0, 1) # Solid black
	left_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aspect_overlay.add_child(left_bar)
	
	right_bar = ColorRect.new()
	right_bar.name = "RightBar"
	right_bar.color = Color(0, 0, 0, 1) # Solid black
	right_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aspect_overlay.add_child(right_bar)
	
	var hud = get_node_or_null("HUD")
	if hud:
		hud.add_child(aspect_overlay)
		hud.move_child(aspect_overlay, 0)
	else:
		add_child(aspect_overlay)
	
	aspect_overlay.resized.connect(_on_aspect_overlay_resized)
	_on_aspect_overlay_resized()
	
	aspect_overlay.visible = not (viewport_container and viewport_container.visible)
	
	# Dynamically center and scale the 2D computer viewport container in 5:4 ratio
	if viewport_container:
		viewport_container.stretch = false
		viewport_container.anchor_left = 0
		viewport_container.anchor_top = 0
		viewport_container.anchor_right = 0
		viewport_container.anchor_bottom = 0
		viewport_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
		viewport_container.grow_vertical = Control.GROW_DIRECTION_BOTH
		
		# Create masks to black out the sides of Aethelgard OS
		os_mask_overlay = Control.new()
		os_mask_overlay.name = "OSSideMasks"
		os_mask_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		os_mask_overlay.anchor_left = 0
		os_mask_overlay.anchor_top = 0
		os_mask_overlay.anchor_right = 1
		os_mask_overlay.anchor_bottom = 1
		os_mask_overlay.offset_left = 0
		os_mask_overlay.offset_top = 0
		os_mask_overlay.offset_right = 0
		os_mask_overlay.offset_bottom = 0
		os_mask_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		os_left_mask = ColorRect.new()
		os_left_mask.name = "LeftMask"
		os_left_mask.color = Color(0, 0, 0, 1) # Solid black
		os_left_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
		os_mask_overlay.add_child(os_left_mask)
		
		os_right_mask = ColorRect.new()
		os_right_mask.name = "RightMask"
		os_right_mask.color = Color(0, 0, 0, 1) # Solid black
		os_right_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
		os_mask_overlay.add_child(os_right_mask)
		
		add_child(os_mask_overlay)
		var original_index = viewport_container.get_index()
		move_child(os_mask_overlay, original_index)
		
		os_mask_overlay.visible = viewport_container.visible
		
		get_viewport().size_changed.connect(_on_viewport_container_resized)
		_on_viewport_container_resized()

func _process(delta):
	# Power grid calculations
	if GameStats.door_locked:
		var drain_rate = 3.5 * (1.0 + (GameStats.current_day - 1) * 0.45)
		GameStats.power_level = max(0.0, GameStats.power_level - drain_rate * delta)
	elif not GameStats.cctv_light_on:
		if GameStats.power_level < 100.0 and not is_breaker_tripped:
			# Recharge power: ~2.5% per second
			GameStats.power_level = min(100.0, GameStats.power_level + 2.5 * delta)

	if GameStats.cctv_light_on:
		GameStats.power_level = max(0.0, GameStats.power_level - 20.0 * delta)
		if GameStats.power_level <= 0.0:
			GameStats.cctv_light_on = false
			var desktop_os = get_node_or_null("ViewportContainer/SubViewport/DesktopOS")
			if desktop_os and desktop_os.has_method("update_cctv_light_state"):
				desktop_os.update_cctv_light_state()

	# Handle Blackout state changes based on power level or breaker state
	if GameStats.power_level <= 0.0 or is_breaker_tripped:
		if not is_blackout:
			GameStats.door_locked = false
			GameStats.cctv_light_on = false
			_trigger_power_outage()
	else:
		if is_blackout and GameStats.power_level >= 10.0 and not is_breaker_tripped:
			_restore_power()

	# Outage timer countdown
	if not is_breaker_tripped and not is_blackout:
		outage_timer -= delta
		if outage_timer <= 0.0:
			trigger_breaker_outage()

	# Creepy flickering corridor light effect
	if corridor_light and randf() < 0.08:
		corridor_light.light_energy = randf_range(0.15, 0.75)
		
	# Update door light mesh material based on global lock state
	_update_door_light_material(GameStats.door_locked)

	# Update door rotation: open (90 deg) unless locked (0 deg)
	if door_mesh:
		if GameStats.door_locked:
			door_mesh.rotation.y = lerp_angle(door_mesh.rotation.y, 0.0, 10.0 * delta)
		else:
			door_mesh.rotation.y = lerp_angle(door_mesh.rotation.y, deg_to_rad(90.0), 10.0 * delta)

	if curtain_node:
		curtain_node.scale.x = lerp(curtain_node.scale.x, target_curtain_scale_x, 8.0 * delta)
		curtain_node.position.x = lerp(curtain_node.position.x, target_curtain_pos_x, 8.0 * delta)

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

func _input(event):
	# Handle closing settings/pause menu when pressing Escape and the menu is open
	var pause_menu = get_node_or_null("HUD/PauseMenu")
	if pause_menu and pause_menu.visible and event.is_action_pressed("ui_cancel"):
		pause_menu.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
		get_viewport().set_input_as_handled()
		return

	# Forward all keyboard events to SubViewport so typing in the Terminal/Notepad works
	if is_inside_tree() and is_instance_valid(sub_viewport) and sub_viewport.is_inside_tree() and viewport_container and viewport_container.visible and not is_blackout and is_monitor_on:
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
	if aspect_overlay:
		aspect_overlay.visible = false
	if os_mask_overlay:
		os_mask_overlay.visible = true

func exit_computer_view():
	# Re-lock mouse and hide 2D overlay
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if viewport_container:
		viewport_container.visible = false
	if reticle:
		reticle.visible = true
	if aspect_overlay:
		aspect_overlay.visible = true
	if os_mask_overlay:
		os_mask_overlay.visible = false

func _on_robot_spawned(_robot_data: RobotData):
	if sprite_3d:
		sprite_3d.visible = false

# Light controls (can be called by light switches or the AE-DOS terminal)
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
	var is_lit = is_ceiling_light_on and not is_blackout
	if desk_light:
		desk_light.visible = is_lit
	var ambient_light = $Lighting/AmbientLight
	if ambient_light:
		ambient_light.visible = is_lit
	if ceiling_bulb:
		var mat = ceiling_bulb.get_active_material(0) as StandardMaterial3D
		if mat:
			if is_lit:
				mat.emission_enabled = true
				mat.emission = Color(1, 0.95, 0.85)
				mat.emission_energy_multiplier = 2.0
				mat.albedo_color = Color(1, 1, 0.9)
			else:
				mat.emission_enabled = false
				mat.albedo_color = Color(0.2, 0.2, 0.2)

func _trigger_power_outage():
	is_blackout = true
	
	# Turn off monitor visually
	if screen_mesh:
		screen_mesh.visible = false
		
	_update_lights_visibility()
	_update_wifi_led_material()
	
	# Close computer apps and release input focus
	if sub_viewport:
		var desktop = sub_viewport.get_node_or_null("Control2/DesktopOS")
		if desktop and desktop.has_method("on_power_outage"):
			desktop.on_power_outage()
		
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
	_update_wifi_led_material()

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

func toggle_wifi():
	GameStats.wifi_on = not GameStats.wifi_on
	_update_wifi_led_material()

func trigger_breaker_outage():
	is_breaker_tripped = true
	GameStats.power_level = 0.0
	GameStats.door_locked = false
	_trigger_power_outage()
	if breaker_lever:
		breaker_lever.rotation.z = deg_to_rad(-45.0)
	var prompt = get_node_or_null("HUD/PromptLabel") as Label
	if prompt:
		prompt.text = "WARNING: POWER BREAKER TRIPPED!"
	print("Power breaker tripped! Plunged into darkness.")

func reset_breaker():
	if is_breaker_tripped or is_blackout:
		is_breaker_tripped = false
		GameStats.power_level = 100.0
		_restore_power()
		if breaker_lever:
			breaker_lever.rotation.z = 0.0
		outage_timer = randf_range(135.0, 270.0)
		var prompt = get_node_or_null("HUD/PromptLabel") as Label
		if prompt:
			prompt.text = "SYSTEM POWER RESTORED."
		print("Power breaker reset. System online.")

func toggle_door_lock():
	if is_blackout:
		return
	GameStats.door_locked = not GameStats.door_locked

func toggle_curtain():
	is_curtain_closed = not is_curtain_closed
	if is_curtain_closed:
		target_curtain_scale_x = 1.0
		target_curtain_pos_x = 0.0
	else:
		target_curtain_scale_x = 0.1
		target_curtain_pos_x = -0.75

func _update_wifi_led_material():
	if wifi_led:
		var mat = wifi_led.get_active_material(0) as StandardMaterial3D
		if mat:
			if is_blackout:
				mat.albedo_color = Color(0.1, 0.1, 0.1) # black/off
				mat.emission = Color(0, 0, 0)
			elif GameStats.wifi_on:
				mat.albedo_color = Color(0, 1, 0) # green
				mat.emission = Color(0, 1, 0)
			else:
				mat.albedo_color = Color(1, 0, 0) # red
				mat.emission = Color(1, 0, 0)

func _on_interact_prompt_changed(text: String):
	$HUD/PromptLabel.text = text

func _double_trigger_enter():
	if not is_inside_tree():
		return
	var tree = get_tree()
	if not tree:
		return
	# Wait a tiny bit to let the first submission finish executing
	await tree.create_timer(0.04).timeout
	if not is_inside_tree() or not is_instance_valid(sub_viewport) or not sub_viewport.is_inside_tree():
		return
	if viewport_container and viewport_container.visible and not is_blackout and is_monitor_on:
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

func _on_aspect_overlay_resized():
	if not aspect_overlay or not left_bar or not right_bar:
		return
	var size = aspect_overlay.size
	var H = size.y
	var W = size.x
	
	if H <= 0 or W <= 0:
		return
		
	var target_aspect = 16.0 / 9.0
	var current_aspect = W / H
	
	if current_aspect > target_aspect:
		# The screen is wider than 16:9 (pillarbox on sides)
		var target_w = H * target_aspect
		var side_w = (W - target_w) / 2.0
		
		left_bar.position = Vector2.ZERO
		left_bar.size = Vector2(side_w, H)
		left_bar.visible = true
		
		right_bar.position = Vector2(W - side_w, 0)
		right_bar.size = Vector2(side_w, H)
		right_bar.visible = true
	else:
		# The screen is taller than 16:9 (letterbox on top/bottom)
		var target_h = W / target_aspect
		var side_h = (H - target_h) / 2.0
		
		left_bar.position = Vector2.ZERO
		left_bar.size = Vector2(W, side_h)
		left_bar.visible = true
		
		right_bar.position = Vector2(0, H - side_h)
		right_bar.size = Vector2(W, side_h)
		right_bar.visible = true

func _on_viewport_container_resized():
	if not viewport_container:
		return
	var size = get_viewport().get_visible_rect().size
	var H = size.y
	var W = size.x
	
	if H <= 0 or W <= 0:
		return
		
	# ALWAYS keep SubViewport fixed at its native 1280x1024 design resolution
	# to prevent internal UI/font scaling distortion
	if sub_viewport and not viewport_container.stretch:
		if sub_viewport.size != Vector2i(1280, 1024):
			sub_viewport.size = Vector2i(1280, 1024)

	var target_w = 1280.0
	var target_h = 1024.0
	
	if W >= 1280.0 and H >= 1024.0:
		# Native 1:1 pixel mapping (unscaled 100% size centered on screen)
		target_w = 1280.0
		target_h = 1024.0
	else:
		# Scale to fit smaller screens while preserving 5:4 aspect ratio
		var target_aspect = 1.25
		var current_aspect = W / H
		if current_aspect > target_aspect:
			target_h = H
			target_w = H * target_aspect
		else:
			target_w = W
			target_h = W / target_aspect
			
	var pos_x = (W - target_w) / 2.0
	var pos_y = (H - target_h) / 2.0
	
	viewport_container.position = Vector2(pos_x, pos_y)
	viewport_container.size = Vector2(target_w, target_h)
		
	# Update the black mask positions to cover areas outside viewport_container
	if os_mask_overlay and os_left_mask and os_right_mask:
		if pos_x > 0:
			# Left mask
			os_left_mask.position = Vector2.ZERO
			os_left_mask.size = Vector2(pos_x, H)
			os_left_mask.visible = true
			
			# Right mask
			os_right_mask.position = Vector2(pos_x + target_w, 0)
			os_right_mask.size = Vector2(W - (pos_x + target_w), H)
			os_right_mask.visible = true
		else:
			# Top mask
			os_left_mask.position = Vector2.ZERO
			os_left_mask.size = Vector2(W, pos_y)
			os_left_mask.visible = true
			
			# Bottom mask
			os_right_mask.position = Vector2(0, pos_y + target_h)
			os_right_mask.size = Vector2(W, H - (pos_y + target_h))
			os_right_mask.visible = true

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
