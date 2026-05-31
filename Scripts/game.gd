extends Control

signal robot_spawned(robot: RobotData)


@onready var robot_texture = %RobotTexture
@onready var good_button = %GoodButton
@onready var bad_button = %BadButton
@onready var chat_button1 = %Button1
@onready var chat_button2 = %Button2
@onready var day_manager = %DayManager
@onready var chat_manager = %ChatManager
@onready var health_bar = %HealthBar
@onready var sanity_bar = %SanityBar

#info tab stuff
@onready var nameInfo = %NameLabel
@onready var modelInfo = %ModelLabel
@onready var statusInfo = %StatusLabel
@onready var manuInfo = %ManuLabel

# --- FLYTTADE VARIABLAR HIT UPP ---
var normal_tex = preload("res://RetroWindowsGUI/Windows_Button.png")
var hover_tex = preload("res://RetroWindowsGUI/Windows_Button_Focus.png")
var pressed_tex = preload("res://RetroWindowsGUI/Windows_Button_Pressed.png")

var robots: Array[RobotData] = []
var current_robot: RobotData
var is_waiting_for_replay = false
var final_message = false

func _ready():
	robots = RobotFactory.create_robots()
	spawn_next_robot()
	health_bar.value = 100
	sanity_bar.value = 100

func spawn_next_robot():
	chat_manager.clear_messages()
	final_message = false
	
	if robots.size() > 0:
		current_robot = pick_next_robot()
		robot_spawned.emit(current_robot)
		chat_manager.add_message(current_robot.robotChat[0], current_robot.name)
		
		chat_button1.text = current_robot.humanChat[chat_manager.chatCount]
		chat_button2.text = current_robot.humanChat[chat_manager.chatCount+1]
		
		# Only update texture if one exists
		if current_robot.sprite:
			robot_texture.texture = current_robot.sprite
		#update inforamtion on the robots
		if current_robot.name:
			nameInfo.text = current_robot.name
		else:
			nameInfo.text = "Unknown"
		
		if current_robot.model:
			modelInfo.text = current_robot.model
		else:
			modelInfo.text = "Unknown"
		
		if current_robot.status:
			statusInfo.text = current_robot.status
		else:
			statusInfo.text = "Unknown"
		
		if current_robot.manufacturer:
			manuInfo.text = current_robot.manufacturer
		else:
			manuInfo.text = "Unknown"
	else:
		print("Error: No robots found in the 'robots' array.")
		
func pick_next_robot():
	if robots.size() <= 1:
		return current_robot
	var next_robot = robots.pick_random()	
	while next_robot == current_robot:
		next_robot = robots.pick_random()
	current_robot = next_robot
	return current_robot
		
func handle_chat_choice(player_text: String, robot_reply: String):
	if is_waiting_for_replay == true:
		return
	is_waiting_for_replay = true
	
	chat_manager.add_message(player_text, "You")
	await get_tree().create_timer(2.0).timeout
	chat_manager.add_message(robot_reply, current_robot.name)
	is_waiting_for_replay = false
	
	if chat_manager.chatCount == 6:
		chat_button1.text = ""
		chat_button2.text = ""
		await get_tree().create_timer(1.0).timeout
		handle_last_terminal_chat()
	else:
		chat_button1.text = current_robot.humanChat[chat_manager.chatCount]
		chat_button2.text = current_robot.humanChat[chat_manager.chatCount+1]

func handle_last_terminal_chat():
	if final_message == false:
		chat_manager.add_message("Inspectation complete. Please issue your final judgment for this AI.", "Terminal: ")
		final_message = true

func _on_good_button_button_down() -> void:
	pass

func _on_good_button_button_up() -> void:
	print("Button Pressed: GOOD (Pass)")
	if current_robot:
		day_manager.process_robot(current_robot, true)
		spawn_next_robot()

func _on_good_button_mouse_entered() -> void:
	pass

func _on_good_button_mouse_exited() -> void:
	pass

func _on_bad_button_button_down() -> void:
	pass

func _on_bad_button_button_up() -> void:
	print("Button Pressed: BAD (Reject)")
	if current_robot:
		day_manager.process_robot(current_robot, false)
		spawn_next_robot()

func _on_bad_button_mouse_entered() -> void:
	pass

func _on_bad_button_mouse_exited() -> void:
	pass

func _on_button_1_button_down() -> void:
	pass

func _on_button_1_button_up() -> void:
	if chat_manager.chatCount > 5:
		return
	handle_chat_choice(current_robot.humanChat[chat_manager.chatCount], current_robot.robotChat[chat_manager.chatCount+1])

func _on_button_2_button_up() -> void:
	if chat_manager.chatCount >= 5:
		return
	handle_chat_choice(current_robot.humanChat[chat_manager.chatCount+1], current_robot.robotChat[chat_manager.chatCount+2])

func _on_button_1_mouse_entered() -> void:
	pass

func _on_button_1_mouse_exited() -> void:
	pass

func _on_button_2_button_down() -> void:
	pass

func _on_button_2_mouse_entered() -> void:
	pass

func _on_button_2_mouse_exited() -> void:
	pass


func _on_quit_button_button_down() -> void:
	pass


func _on_quit_button_button_up() -> void:
	get_tree().quit()


func _on_quit_button_mouse_entered() -> void:
	pass


func _on_quit_button_mouse_exited() -> void:
	pass

func _on_good_button_pressed() -> void:
	_on_good_button_button_up()

func _on_bad_button_pressed() -> void:
	_on_bad_button_button_up()

func _on_chat_button1_pressed() -> void:
	_on_button_1_button_up()

func _on_chat_button2_pressed() -> void:
	_on_button_2_button_up()

func _process(_delta):
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		var last_idx = crt.get_parent().get_child_count() - 1
		if crt.get_index() != last_idx:
			crt.get_parent().move_child(crt, last_idx)
