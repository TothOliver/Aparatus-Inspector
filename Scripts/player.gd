extends CharacterBody3D
class_name PlayerController

@export var speed: float = 2.0
@export var mouse_sensitivity: float = 0.15
@export var gravity: float = 9.8
@export var lerp_speed: float = 8.0

@onready var camera = $Camera3D
@onready var interaction_ray = $Camera3D/InteractionRay

enum State {
	WALKING,
	COMPUTER_VIEW
}

var current_state = State.WALKING
var is_crouching: bool = false

# Movement variables
var rotation_x: float = 0.0
var rotation_y: float = 0.0

# Camera heights
var stand_cam_y: float = 1.55
var crouch_cam_y: float = 0.75

# Sit positions
var sit_pos: Vector3 = Vector3(0, 0, 0.48)
var stand_exit_pos: Vector3 = Vector3(0, 0.05, 1.45)

# Interaction prompt
signal interact_prompt_changed(text: String)

# Flashlight variables
var flashlight: SpotLight3D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.position.y = stand_cam_y
	
	if "fov" in GameStats:
		camera.fov = GameStats.fov
	if GameStats.has_signal("fov_changed") and not GameStats.fov_changed.is_connected(_on_fov_changed):
		GameStats.fov_changed.connect(_on_fov_changed)
	
	# Create flashlight dynamically
	flashlight = SpotLight3D.new()
	flashlight.name = "Flashlight"
	flashlight.visible = false
	flashlight.light_energy = 2.5
	flashlight.spot_range = 15.0
	flashlight.spot_angle = 35.0
	flashlight.shadow_enabled = true
	flashlight.position = Vector3(0, 0, 0)
	flashlight.rotation = Vector3(0, 0, 0)
	camera.add_child(flashlight)

func _on_fov_changed(new_fov: float):
	if camera:
		camera.fov = new_fov

func _physics_process(delta):
	if current_state == State.WALKING:
		handle_walking_movement(delta)
	elif current_state == State.COMPUTER_VIEW:
		is_crouching = false
		handle_computer_view(delta)

func _process(_delta):
	# Check for interaction raycasts
	check_interaction()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		handle_settings_shortcut()

func handle_walking_movement(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Crouch
	var target_cam_y = stand_cam_y
	var collider_shape = $CollisionShape3D.shape as CapsuleShape3D
	
	var is_crouch_pressed = false
	if InputMap.has_action("crouch"):
		is_crouch_pressed = Input.is_action_pressed("crouch")
	else:
		is_crouch_pressed = Input.is_key_pressed(KEY_CTRL)
		
	if is_crouch_pressed:
		target_cam_y = crouch_cam_y
		collider_shape.height = 1.0
		is_crouching = true
	else:
		collider_shape.height = 1.8
		is_crouching = false
	
	# Smoothly interpolate camera height and zoom out
	camera.position.y = lerp(camera.position.y, target_cam_y, lerp_speed * delta)
	camera.position.x = lerp(camera.position.x, 0.0, lerp_speed * delta)
	camera.position.z = lerp(camera.position.z, 0.0, lerp_speed * delta)
	
	# Get input direction
	var input_dir = Vector2.ZERO
	var has_move_actions = InputMap.has_action("move_left") and InputMap.has_action("move_right") and InputMap.has_action("move_forward") and InputMap.has_action("move_backward")
	if has_move_actions:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	else:
		# Fallback if actions are not mapped
		var x_input = 0.0
		var z_input = 0.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): x_input -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): x_input += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): z_input -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): z_input += 1.0
		input_dir = Vector2(x_input, z_input).normalized()
	
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if dir:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()



func handle_computer_view(delta):
	# Smoothly position player at chair, zoom camera into screen
	global_position = global_position.lerp(sit_pos, lerp_speed * delta)
	rotation.y = lerp_angle(rotation.y, 0.0, lerp_speed * delta)
	camera.position = camera.position.lerp(Vector3(0, 0.9, -0.22), lerp_speed * delta)
	camera.transform.basis = camera.transform.basis.slerp(Basis.IDENTITY, lerp_speed * delta)

func _input(event):
	# Toggle flashlight
	var flashlight_pressed = false
	if InputMap.has_action("toggle_flashlight"):
		if event.is_action_pressed("toggle_flashlight"):
			flashlight_pressed = true
	else:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F:
			flashlight_pressed = true
			
	if flashlight_pressed:
		if flashlight:
			flashlight.visible = not flashlight.visible

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var active_sens = GameStats.mouse_sensitivity if "mouse_sensitivity" in GameStats else mouse_sensitivity
		if current_state == State.WALKING:
			# Modify player rotation (yaw) and camera rotation (pitch)
			rotate_y(deg_to_rad(-event.relative.x * active_sens))
			camera.rotate_x(deg_to_rad(-event.relative.y * active_sens))
			# Clamp camera pitch to look straight down / straight up
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))


	# Handle interaction trigger exactly once when key/button is pressed
	if current_state != State.COMPUTER_VIEW and event.is_pressed():
		var is_interact_pressed = false
		if InputMap.has_action("interact"):
			if event.is_action("interact"):
				is_interact_pressed = true
		else:
			if event is InputEventKey and event.keycode == KEY_E:
				is_interact_pressed = true
				
		if not is_interact_pressed and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			is_interact_pressed = true
			
		if is_interact_pressed:
			if interaction_ray.is_colliding():
				var collider = interaction_ray.get_collider()
				if collider:
					if collider.has_method("interact"):
						collider.interact(self)
					elif collider.name.contains("Screen") or collider.name.contains("Computer") or collider.name.contains("Monitor"):
						if not is_power_off():
							interact_with_computer()

					elif collider.name.contains("Breaker") or collider.name.contains("Fuse"):
						var parent = get_parent()
						if parent and parent.has_method("reset_breaker"):
							parent.reset_breaker()

func is_power_off() -> bool:
	var game_3d = get_tree().current_scene
	if game_3d and "is_blackout" in game_3d:
		return game_3d.is_blackout
	return false

func is_interactable(collider) -> bool:
	if not collider:
		return false
	if collider.has_method("interact"):
		return true
	var name_lower = collider.name.to_lower()
	if name_lower.contains("screen") or name_lower.contains("computer") or name_lower.contains("monitor"):
		return not is_power_off()
	if name_lower.contains("curtain") or name_lower.contains("breaker") or name_lower.contains("fuse"):
		return true
	return false

func check_interaction():
	if current_state == State.COMPUTER_VIEW:
		interact_prompt_changed.emit("")
		return

	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider and is_interactable(collider):
			var target_name = ""
			if collider.has_method("get_interact_name"):
				target_name = collider.get_interact_name()
			else:
				target_name = collider.name
			
			var key_name = "E"
			if InputMap.has_action("interact"):
				var events = InputMap.action_get_events("interact")
				if events.size() > 0 and events[0] is InputEventKey:
					key_name = OS.get_keycode_string(events[0].keycode)
			interact_prompt_changed.emit("Press " + key_name + " or Left Click to interact with: " + target_name)
		else:
			interact_prompt_changed.emit("")
	else:
		interact_prompt_changed.emit("")

func interact_with_computer():
	if is_power_off():
		return
	var game_3d = get_tree().current_scene
	if game_3d and "is_blackout" in game_3d:
		if not game_3d.is_monitor_on and not game_3d.is_blackout:
			game_3d.toggle_monitor_power()
	
	# Transition directly to computer view
	current_state = State.COMPUTER_VIEW
	# Tell Game3D to zoom in and release mouse
	if game_3d and game_3d.has_method("enter_computer_view"):
		game_3d.enter_computer_view()

func exit_computer_view():
	current_state = State.WALKING
	global_position = stand_exit_pos
	velocity = Vector3.ZERO
	camera.position = Vector3(0, stand_cam_y, 0)
	camera.transform.basis = Basis.IDENTITY
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var game_3d = get_tree().current_scene
	if game_3d and game_3d.has_method("exit_computer_view"):
		game_3d.exit_computer_view()

func handle_settings_shortcut():
	var game_3d = get_tree().current_scene
	if not game_3d:
		return
		
	if current_state == State.COMPUTER_VIEW:
		exit_computer_view()
	else:
		var pause_menu = game_3d.get_node_or_null("HUD/PauseMenu")
		if pause_menu:
			if pause_menu.visible:
				pause_menu.visible = false
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				get_tree().paused = false
				get_viewport().set_input_as_handled()
			else:
				pause_menu.visible = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				get_tree().paused = true
				get_viewport().set_input_as_handled()
