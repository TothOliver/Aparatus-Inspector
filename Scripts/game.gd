extends Control

signal robot_spawned(robot: RobotData)


@onready var robot_texture = %RobotTexture
@onready var good_button = %GoodButton
@onready var bad_button = %BadButton
@onready var chat_button1 = %Button1
@onready var chat_button2 = %Button2
@onready var chat_button3 = %Button3
@onready var question_input = %QuestionInput
@onready var submit_question_button = %SubmitQuestionButton
@onready var day_manager = %DayManager
@onready var chat_manager = %ChatManager
@onready var health_bar = %HealthBar
@onready var sanity_bar = %SanityBar

#info tab stuff
@onready var nameInfo = %NameLabel
@onready var modelInfo = %ModelLabel
@onready var statusInfo = %StatusLabel
@onready var manuInfo = %ManuLabel
@onready var quotaLabel = %QuotaLabel

# --- FLYTTADE VARIABLAR HIT UPP ---
var normal_tex = preload("res://RetroWindowsGUI/Windows_Button.png")
var hover_tex = preload("res://RetroWindowsGUI/Windows_Button_Focus.png")
var pressed_tex = preload("res://RetroWindowsGUI/Windows_Button_Pressed.png")

var robots: Array[RobotData] = []
var current_robot: RobotData
var is_waiting_for_replay = false
var final_message = false
var is_processing_choice = false
var was_wifi_on: bool = true
var robots_picked_count: int = 0

const QUESTIONS_PER_PAGE := 2
var question_page_start := 0

func _ready():
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		crt.add_to_group("CRTOverlays")
	
	question_input.text_submitted.connect(_on_question_input_submitted)
	submit_question_button.pressed.connect(_on_submit_question_button_pressed)	
		
	robots = RobotFactory.create_robots()
	was_wifi_on = GameStats.wifi_on
	spawn_next_robot()
	health_bar.value = GameStats.player_health
	sanity_bar.value = GameStats.player_sanity

func spawn_next_robot():
	if not is_inside_tree():
		return
	chat_manager.clear_messages()
	final_message = false
	
	# Check if WiFi is offline
	if not GameStats.wifi_on:
		robot_spawned.emit(null)
		robot_texture.texture = null
		nameInfo.text = "N/A"
		modelInfo.text = "N/A"
		statusInfo.text = "N/A"
		manuInfo.text = "N/A"
		if quotaLabel:
			quotaLabel.text = "N/A"
		chat_button1.text = ""
		chat_button2.text = ""
		good_button.disabled = true
		bad_button.disabled = true
		chat_manager.add_message("CONNECTION LOST: WiFi network is offline. Please check physical router or terminal network settings.", "System Error")
		return
	
	# Check if daily quota has been met
	var current_day = day_manager.current_day
	var quota = 3
	if current_day in day_manager.day_configs:
		quota = day_manager.day_configs[current_day].quota
		
	if quotaLabel:
		quotaLabel.text = "%d / %d" % [day_manager.processed_today, quota]
		
	if day_manager.processed_today >= quota:
		current_robot = null
		robot_spawned.emit(null)
		robot_texture.texture = null
		nameInfo.text = "N/A"
		modelInfo.text = "N/A"
		statusInfo.text = "N/A"
		manuInfo.text = "N/A"
		clear_question_buttons()
		good_button.disabled = true
		bad_button.disabled = true
		chat_manager.add_message("Shift quota complete. Authorizing shift exit...", "System")
		await get_tree().create_timer(1.5).timeout
		day_manager.end_day()
		return
	
	if robots.size() > 0:
		good_button.disabled = false
		bad_button.disabled = false
		if not current_robot:
			current_robot = pick_next_robot()
		robot_spawned.emit(current_robot)
		chat_manager.add_message(current_robot.robotChat[0], current_robot.name)
		
		question_page_start = 0
		refresh_question_buttons()
		
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
		
	var current_day = day_manager.current_day
	var index_to_pick = -1
	
	if robots.size() > 9:
		if current_day == 1:
			if robots_picked_count == 2:
				index_to_pick = 3 # Walter (H.U.G.O) always last on Day 1
		elif current_day == 2:
			match robots_picked_count:
				2: index_to_pick = 2 # Larry (S80) - Essential bribe clue
				# All other slots on Day 2 are randomly generated
		elif current_day == 3:
			match robots_picked_count:
				3: index_to_pick = 3 # Walter clone - Essential key clue
				# All other slots on Day 3 are randomly generated
				
	robots_picked_count += 1
	
	if index_to_pick != -1 and index_to_pick < robots.size():
		current_robot = robots[index_to_pick]
		return current_robot
		
	# Fallback to random pick from procedural pool (indices 10 onwards)
	var procedural_robots = robots.slice(10) if robots.size() > 10 else robots
	var next_robot = procedural_robots.pick_random()
	while next_robot == current_robot:
		next_robot = procedural_robots.pick_random()
	current_robot = next_robot
	return current_robot
	
func trigger_walter_escape():
	good_button.disabled = true
	bad_button.disabled = true
	chat_button1.text = ""
	chat_button2.text = ""
	
	# Disappear the robot's viewport mesh/texture immediately
	robot_texture.texture = null
	nameInfo.text = "ERROR"
	modelInfo.text = "ERROR"
	statusInfo.text = "CONTAINMENT BREACH"
	manuInfo.text = "ERROR"
	
	chat_manager.clear_messages()
	chat_manager.add_message("[SYSTEM WARNING] DISPOSAL PATHWAY GATE VALVE FAILURE DETECTED.", "System Alert")
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree(): return
	chat_manager.add_message("[SYSTEM ERROR] CHASSIS FORCE OVERRIDE: HYDRAULICS SNAP OVERRIDE BY UNIT H-01.", "System Alert")
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree(): return
	chat_manager.add_message("[SYSTEM WARNING] UNIT H-01 'WALTER' HAS DEACTIVATED VIEWPORT FEEDS AND FORCED OUTER GATES OPEN. TARGET ESCAPED INTO CORRIDOR SECTOR B.", "System Alert")
	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree(): return
	
	# Transition directly to the next day
	day_manager.end_day()
		
func handle_chat_choice(player_text: String, robot_reply: String):
	if is_waiting_for_replay == true:
		return
	is_waiting_for_replay = true
	
	if is_inside_tree() and chat_manager:
		chat_manager.add_message(player_text, "You")
	
	if not is_inside_tree() or not get_tree():
		is_waiting_for_replay = false
		return
	await get_tree().create_timer(0.4).timeout
	
	if not is_inside_tree() or not chat_manager:
		is_waiting_for_replay = false
		return
	chat_manager.add_message(robot_reply, current_robot.name)
	is_waiting_for_replay = false
	
	question_page_start += QUESTIONS_PER_PAGE

	if question_page_start >= current_robot.humanChat.size():
		clear_question_buttons()

		if not is_inside_tree() or not get_tree():
			return

		await get_tree().create_timer(0.3).timeout

		if not is_inside_tree():
			return

		handle_last_terminal_chat()
	else:
		refresh_question_buttons()

func handle_last_terminal_chat():
	if not is_inside_tree() or not chat_manager:
		return
	if final_message == false:
		chat_manager.add_message("Inspectation complete. Please issue your final judgment for this AI.", "Terminal: ")
		final_message = true

func _on_good_button_button_down() -> void:
	pass

func _on_good_button_button_up() -> void:
	pass

func _on_good_button_mouse_entered() -> void:
	pass

func _on_good_button_mouse_exited() -> void:
	pass

func _on_bad_button_button_down() -> void:
	pass

func _on_bad_button_button_up() -> void:
	pass

func _on_bad_button_mouse_entered() -> void:
	pass

func _on_bad_button_mouse_exited() -> void:
	pass

func _on_button_1_button_down() -> void:
	pass

func _on_button_1_button_up() -> void:
	ask_question_at_index(question_page_start)

func _on_button_2_button_up() -> void:
	ask_question_at_index(question_page_start + 1)	

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
		GameStats.quit_or_menu(get_tree())
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
	if is_processing_choice:
		return
	is_processing_choice = true
	print("Button Pressed: GOOD (Pass)")
	if current_robot:
		if current_robot.name == "Walter" and day_manager.current_day == 1:
			trigger_walter_escape()
			return
		day_manager.process_robot(current_robot, true)
		current_robot = null
		spawn_next_robot()
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(0.25).timeout
		is_processing_choice = false

func _on_bad_button_pressed() -> void:
	if is_processing_choice:
		return
	is_processing_choice = true
	print("Button Pressed: BAD (Reject)")
	if current_robot:
		if current_robot.name == "Walter" and day_manager.current_day == 1:
			trigger_walter_escape()
			return
		day_manager.process_robot(current_robot, false)
		current_robot = null
		spawn_next_robot()
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(0.25).timeout
		is_processing_choice = false

func _on_chat_button1_pressed() -> void:
	_on_button_1_button_up()

func _on_chat_button2_pressed() -> void:
	_on_button_2_button_up()
	
func _on_question_input_submitted(text: String) -> void:
	submit_question_text(text)
	
func _on_submit_question_button_pressed() -> void:
	submit_question_text(question_input.text)
	
func fill_question_input(question_index: int) -> void:
	if current_robot == null:
		return
		
	if question_index < 0 or question_index >= current_robot.humanChat.size():
		return
	
	question_input.text = current_robot.humanChat[question_index]
	question_input.grab_focus()
	question_input.caret_column = question_input.text.length()

func submit_question_text(text: String) -> void:
	if current_robot == null:
		return
	
	if is_waiting_for_replay:
		return
		
	var cleaned_text := text.strip_edges()
	
	if cleaned_text.is_empty():
		return
		
	var question_index := find_exact_question_match(cleaned_text)
	
	if question_index == -1:
		chat_manager.add_message(cleaned_text, "You")
		chat_manager.add_message("QUERY NOT REGOGNIZED.", "Terminal") #robot answer?
		question_input.clear()
		return
	
	question_input.clear()
	ask_question_at_index(question_index)

func find_exact_question_match(text: String) -> int:
	if current_robot == null:
		return -1
	
	var normalized_input := normalize_question_text(text)
	for i in range(current_robot.humanChat.size()):
		var normalized_question := normalize_question_text(current_robot.humanChat[i])
		
		if normalized_input == normalized_question:
			return i
	return -1
	
func normalize_question_text(text: String) -> String:
	var result := text.to_lower().strip_edges()
	
	var chars_to_remove := [".", ",", "?", "!", ":", ";", "'", "\""]
	for c in chars_to_remove:
		result = result.replace(c, "")
	
	return result

func _process(_delta):
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		if crt.z_index != 20:
			crt.z_index = 20
		var last_idx = crt.get_parent().get_child_count() - 1
		if crt.get_index() != last_idx:
			crt.get_parent().move_child(crt, last_idx)
			
	# WiFi connection listener
	if was_wifi_on != GameStats.wifi_on:
		was_wifi_on = GameStats.wifi_on
		spawn_next_robot()

func clear_question_buttons() -> void:
	chat_button1.text = ""
	chat_button2.text = ""
	chat_button1.disabled = true
	chat_button2.disabled = true

func refresh_question_buttons() -> void:
	if current_robot == null:
		clear_question_buttons()
		return
	
	set_question_button(chat_button1, question_page_start)
	set_question_button(chat_button2, question_page_start +1)
	
func set_question_button(button: Button, question_index: int) -> void:
	if current_robot == null:
		button.text = ""
		button.disabled = true
		return
	
	if question_index >= 0 and question_index < current_robot.humanChat.size():
		button.text = current_robot.humanChat[question_index]
		button.disabled = false
	else:
		button.text = ""
		button.disabled = true

func ask_question_at_index(question_index: int) -> void:
	if current_robot == null:
		return

	if is_waiting_for_replay:
		return

	if question_index < 0 or question_index >= current_robot.humanChat.size():
		return

	var player_text := current_robot.humanChat[question_index]
	var robot_reply_index := question_index + 1

	if robot_reply_index < 0 or robot_reply_index >= current_robot.robotChat.size():
		push_warning("Missing robot reply for question index: " + str(question_index))
		return

	var robot_reply := current_robot.robotChat[robot_reply_index]
	handle_chat_choice(player_text, robot_reply)
