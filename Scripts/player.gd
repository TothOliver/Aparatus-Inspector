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
	SITTING,
	COMPUTER_VIEW
}

var current_state = State.WALKING

# Movement variables
var rotation_x: float = 0.0
var rotation_y: float = 0.0

# Camera heights
var stand_cam_y: float = 1.55
var crouch_cam_y: float = 0.75
var sit_cam_y: float = 1.05

# Sit positions
var sit_pos: Vector3 = Vector3(0, 0, 0.48)
var stand_exit_pos: Vector3 = Vector3(0, 0.05, 1.45)

# Clamped mouse variables for SITTING state
var sit_yaw: float = 0.0
var sit_pitch: float = 0.0
var max_sit_yaw: float = 65.0
var max_sit_pitch: float = 30.0

# Interaction prompt
signal interact_prompt_changed(text: String)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.position.y = stand_cam_y

func _physics_process(delta):
	if current_state == State.WALKING:
		handle_walking_movement(delta)
	elif current_state == State.SITTING:
		handle_sitting_camera(delta)
	elif current_state == State.COMPUTER_VIEW:
		handle_computer_view(delta)

func _process(delta):
	# Check for interaction raycasts
	check_interaction()

func handle_walking_movement(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Crouch
	var target_cam_y = stand_cam_y
	var collider_shape = $CollisionShape3D.shape as CapsuleShape3D
	
	var is_crouch_pressed = false
	if InputMap.has_action("crouch") and Input.is_action_pressed("crouch"):
		is_crouch_pressed = true
		
	if is_crouch_pressed or Input.is_key_pressed(KEY_CTRL):
		target_cam_y = crouch_cam_y
		collider_shape.height = 1.0
	else:
		collider_shape.height = 1.8
	
	# Smoothly interpolate camera height and zoom out
	camera.position.y = lerp(camera.position.y, target_cam_y, lerp_speed * delta)
	camera.position.x = lerp(camera.position.x, 0.0, lerp_speed * delta)
	camera.position.z = lerp(camera.position.z, 0.0, lerp_speed * delta)
	
	# Get input direction
	var input_dir = Vector2.ZERO
	if InputMap.has_action("move_left") and InputMap.has_action("move_right") and InputMap.has_action("move_forward") and InputMap.has_action("move_backward"):
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		
	# Fallback if actions are not mapped or are zero
	if input_dir == Vector2.ZERO:
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

func handle_sitting_camera(delta):
	# Smoothly interpolate player position and rotation to the chair
	global_position = global_position.lerp(sit_pos, lerp_speed * delta)
	rotation.y = lerp_angle(rotation.y, 0.0, lerp_speed * delta)
	camera.position.y = lerp(camera.position.y, sit_cam_y, lerp_speed * delta)
	camera.position.x = lerp(camera.position.x, 0.0, lerp_speed * delta)
	camera.position.z = lerp(camera.position.z, 0.0, lerp_speed * delta)
	
	# Let player look around but keep head rotation clamped
	var rot_target = Basis.IDENTITY
	rot_target = rot_target.rotated(Vector3.UP, deg_to_rad(sit_yaw))
	rot_target = rot_target.rotated(Vector3.RIGHT, deg_to_rad(sit_pitch))
	camera.transform.basis = camera.transform.basis.slerp(rot_target, lerp_speed * delta)
	
	# Check for standing up
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) or Input.is_action_just_pressed("ui_cancel"):
		stand_up()

func handle_computer_view(delta):
	# Smoothly position player at chair, zoom camera into screen
	global_position = global_position.lerp(sit_pos, lerp_speed * delta)
	rotation.y = lerp_angle(rotation.y, 0.0, lerp_speed * delta)
	camera.position = camera.position.lerp(Vector3(0, 0.9, -0.22), lerp_speed * delta)
	camera.transform.basis = camera.transform.basis.slerp(Basis.IDENTITY, lerp_speed * delta)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if current_state == State.WALKING:
			# Modify player rotation (yaw) and camera rotation (pitch)
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			# Clamp camera pitch to look straight down / straight up
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		elif current_state == State.SITTING:
			# Accumulate sitting look angles
			sit_yaw -= event.relative.x * mouse_sensitivity
			sit_pitch -= event.relative.y * mouse_sensitivity
			
			sit_yaw = clamp(sit_yaw, -max_sit_yaw, max_sit_yaw)
			sit_pitch = clamp(sit_pitch, -max_sit_pitch, max_sit_pitch)

func check_interaction():
	if current_state == State.COMPUTER_VIEW:
		# In computer view, ESC exits
		if Input.is_action_just_pressed("ui_cancel"):
			exit_computer_view()
		return

	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()
		if collider:
			var target_name = ""
			if collider.has_method("get_interact_name"):
				target_name = collider.get_interact_name()
			else:
				target_name = collider.name
			
			interact_prompt_changed.emit("Press E or Left Click to interact with: " + target_name)
			
			var is_interact_pressed = false
			if InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
				is_interact_pressed = true
				
			if is_interact_pressed or Input.is_key_pressed(KEY_E) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				if collider.has_method("interact"):
					collider.interact(self)
				elif collider.name.contains("Screen") or collider.name.contains("Computer") or collider.name.contains("Monitor"):
					interact_with_computer()
				elif collider.name.contains("Chair"):
					sit_down()
	else:
		interact_prompt_changed.emit("")

func sit_down():
	if current_state == State.WALKING:
		current_state = State.SITTING
		sit_yaw = 0.0
		sit_pitch = 0.0
		# Lock mouse
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func stand_up():
	if current_state == State.SITTING:
		current_state = State.WALKING
		global_position = stand_exit_pos
		velocity = Vector3.ZERO
		camera.position = Vector3(0, stand_cam_y, 0)
		camera.transform.basis = Basis.IDENTITY

func interact_with_computer():
	if current_state == State.WALKING:
		sit_down()
	
	# Transition directly to computer view
	current_state = State.COMPUTER_VIEW
	# Tell Game3D to zoom in and release mouse
	var game_3d = get_tree().root.get_node_or_null("Game3D")
	if game_3d:
		game_3d.enter_computer_view()

func exit_computer_view():
	current_state = State.WALKING
	global_position = stand_exit_pos
	velocity = Vector3.ZERO
	camera.position = Vector3(0, stand_cam_y, 0)
	camera.transform.basis = Basis.IDENTITY
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var game_3d = get_tree().root.get_node_or_null("Game3D")
	if game_3d:
		game_3d.exit_computer_view()
