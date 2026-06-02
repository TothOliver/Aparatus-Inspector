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
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		crt.add_to_group("CRTOverlays")
	robots = RobotFactory.create_robots()
	spawn_next_robot()
	health_bar.value = 100
	sanity_bar.value = 100

func spawn_next_robot():
	if not is_inside_tree():
		return
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
	
	if is_inside_tree() and chat_manager:
		chat_manager.add_message(player_text, "You")
	
	if not is_inside_tree() or not get_tree():
		is_waiting_for_replay = false
		return
	await get_tree().create_timer(2.0).timeout
	
	if not is_inside_tree() or not chat_manager:
		is_waiting_for_replay = false
		return
	chat_manager.add_message(robot_reply, current_robot.name)
	is_waiting_for_replay = false
	
	if chat_manager.chatCount == 6:
		chat_button1.text = ""
		chat_button2.text = ""
		if not is_inside_tree() or not get_tree():
			return
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree():
			return
		handle_last_terminal_chat()
	else:
		if current_robot:
			chat_button1.text = current_robot.humanChat[chat_manager.chatCount]
			chat_button2.text = current_robot.humanChat[chat_manager.chatCount+1]

func handle_last_terminal_chat():
	if not is_inside_tree() or not chat_manager:
		return
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
	var parent_size = size if size != Vector2.ZERO else Vector2(1280, 1024)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.4)
	overlay.size = parent_size
	overlay.position = Vector2.ZERO
	add_child(overlay)
	
	var dialog = NinePatchRect.new()
	dialog.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	dialog.patch_margin_left = 12
	dialog.patch_margin_top = 12
	dialog.patch_margin_right = 12
	dialog.patch_margin_bottom = 12
	dialog.size = Vector2(280, 140)
	dialog.position = (parent_size - dialog.size) / 2.0
	overlay.add_child(dialog)
	
	var title_bar = NinePatchRect.new()
	title_bar.texture = preload("res://RetroWindowsGUI/Window_Header.png")
	title_bar.region_rect = Rect2(0, 0, 48, 25)
	title_bar.patch_margin_left = 5
	title_bar.patch_margin_top = 3
	title_bar.patch_margin_right = 5
	title_bar.patch_margin_bottom = 3
	title_bar.position = Vector2(6, 6)
	title_bar.size = Vector2(dialog.size.x - 12, 30)
	dialog.add_child(title_bar)
	
	var title_label = Label.new()
	title_label.text = "Exit Game"
	title_label.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.position = Vector2(8, 6)
	title_bar.add_child(title_label)
	
	var msg_label = Label.new()
	msg_label.text = "Do you want to quit game?"
	msg_label.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
	msg_label.add_theme_font_size_override("font_size", 12)
	msg_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	msg_label.position = Vector2(10, 45)
	msg_label.size = Vector2(dialog.size.x - 20, 30)
	dialog.add_child(msg_label)
	
	var yes_btn = Button.new()
	yes_btn.text = "Yes"
	yes_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
	yes_btn.add_theme_font_size_override("font_size", 12)
	yes_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	yes_btn.add_theme_stylebox_override("normal", preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres"))
	yes_btn.add_theme_stylebox_override("hover", preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres"))
	yes_btn.add_theme_stylebox_override("pressed", preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres"))
	yes_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	yes_btn.position = Vector2(45, 90)
	yes_btn.size = Vector2(85, 30)
	yes_btn.pressed.connect(func():
		get_tree().quit()
	)
	dialog.add_child(yes_btn)
	
	var no_btn = Button.new()
	no_btn.text = "No"
	no_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
	no_btn.add_theme_font_size_override("font_size", 12)
	no_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	no_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	no_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	no_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	no_btn.add_theme_stylebox_override("normal", preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres"))
	no_btn.add_theme_stylebox_override("hover", preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres"))
	no_btn.add_theme_stylebox_override("pressed", preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres"))
	no_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	no_btn.position = Vector2(150, 90)
	no_btn.size = Vector2(85, 30)
	no_btn.pressed.connect(func():
		overlay.queue_free()
	)
	dialog.add_child(no_btn)


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
		if crt.z_index != 20:
			crt.z_index = 20
		var last_idx = crt.get_parent().get_child_count() - 1
		if crt.get_index() != last_idx:
			crt.get_parent().move_child(crt, last_idx)
