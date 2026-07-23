extends Control

signal robot_spawned(robot: RobotData)


@onready var robot_texture = %RobotTexture
@onready var good_button = %GoodButton
@onready var bad_button = %BadButton
@onready var chat_button1: Button = %Button1
@onready var chat_button2: Button = %Button2
@onready var chat_button3: Button = %Button3
@onready var question_input: LineEdit = %QuestionInput
@onready var submit_question_button: Button = %SubmitQuestionButton
@onready var day_manager = %DayManager
@onready var chat_manager = %ChatManager
@onready var health_bar = %HealthBar

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
var question_dropdown_panel: NinePatchRect

func _ready():
	# Resize and reposition ApparatusInspectorWindow to fit at smallest size (850x620) and scale cleanly
	var inspector = get_node_or_null("ApparatusInspectorWindow") as NinePatchRect
	if inspector:
		inspector.custom_minimum_size = Vector2(850, 620)
		inspector.size = Vector2(850, 620)
		inspector.position = Vector2(200, 50)
		
		var title_bar_node = inspector.get_node_or_null("TitleBar") as Control
		if title_bar_node:
			title_bar_node.size.x = 838
			var close_btn = title_bar_node.get_node_or_null("CloseButton") as Button
			if close_btn:
				close_btn.position.x = 813
		
		# Left side: Picture & AcceptTerminate (Width = 230)
		var pic = inspector.get_node_or_null("Picture") as Control
		if pic:
			pic.position = Vector2(15, 45)
			pic.size = Vector2(230, 270)
			var diag_lbl = pic.get_node_or_null("DiagLabel") as Label
			if diag_lbl:
				diag_lbl.position = Vector2(10, 244)

		var accept_term = inspector.get_node_or_null("AcceptTerminate") as Control
		if accept_term:
			accept_term.position = Vector2(15, 335)
			accept_term.size = Vector2(230, 270)
			
			var app_info = accept_term.get_node_or_null("ApproveInfo") as Label
			if app_info:
				app_info.text = "APPROVE:\nPass to grid service."
				app_info.position = Vector2(12, 18)
				app_info.size = Vector2(206, 34)
				
			var good_btn = accept_term.get_node_or_null("ButtonPanel/GoodButton") as Button
			if good_btn:
				good_btn.position = Vector2(10, 72)
				good_btn.size = Vector2(210, 46)
				
			var ext_info = accept_term.get_node_or_null("ExterminateInfo") as Label
			if ext_info:
				ext_info.text = "EXTERMINATE:\nFlag for disposal."
				ext_info.position = Vector2(12, 134)
				ext_info.size = Vector2(206, 34)
				
			var bad_btn = accept_term.get_node_or_null("ButtonPanel/BadButton") as Button
			if bad_btn:
				bad_btn.position = Vector2(10, 188)
				bad_btn.size = Vector2(210, 46)

		# Middle side: ChatManager and Option (Width = 330)
		var chat_manager_node = inspector.get_node_or_null("ChatManager") as Control
		if chat_manager_node:
			chat_manager_node.position = Vector2(255, 45)
			chat_manager_node.size = Vector2(330, 435)
			
		var option_node = inspector.get_node_or_null("Option") as Control
		if option_node:
			option_node.position = Vector2(255, 490)
			option_node.size = Vector2(330, 115)

			var ans_panel = option_node.get_node_or_null("AnswerPanel") as Panel
			if ans_panel:
				ans_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

			var label = option_node.get_node_or_null("OptionGroupLabel") as Label
			if label:
				label.position = Vector2(15, -8)
				label.size = Vector2(160, 16)

			var btn1 = option_node.get_node_or_null("Button1") as Button
			if btn1:
				btn1.visible = true
				btn1.position = Vector2(10, 18)
				btn1.size = Vector2(310, 38)
				btn1.autowrap_mode = TextServer.AUTOWRAP_OFF
				btn1.clip_text = true
				btn1.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
				btn1.text = "▲  Select Question..."

			var btn2 = option_node.get_node_or_null("Button2") as Button
			if btn2:
				btn2.visible = false
				btn2.disabled = true

			var btn3 = option_node.get_node_or_null("Button3") as Button
			if btn3:
				btn3.visible = false
				btn3.disabled = true

			var input = option_node.get_node_or_null("QuestionInput") as LineEdit
			if input:
				input.visible = true
				input.position = Vector2(10, 64)
				input.size = Vector2(255, 34)
				input.placeholder_text = "Type question..."
				var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
				var inner_frame = preload("res://RetroWindowsGUI/StyleBox_Inner_Frame.tres")
				input.add_theme_font_override("font", font_bold)
				input.add_theme_font_size_override("font_size", 12)
				input.add_theme_color_override("font_color", Color(0, 0, 0, 1))
				input.add_theme_color_override("font_placeholder_color", Color(0.4, 0.4, 0.4, 1))
				input.add_theme_color_override("caret_color", Color(0, 0, 0, 1))
				input.add_theme_stylebox_override("normal", inner_frame)
				input.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

			var submit = option_node.get_node_or_null("SubmitQuestionButton") as Button
			if submit:
				submit.visible = true
				submit.position = Vector2(275, 64)
				submit.size = Vector2(45, 34)
				submit.text = ">"
				var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
				var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
				var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
				var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
				submit.add_theme_font_override("font", font_bold)
				submit.add_theme_font_size_override("font_size", 14)
				submit.add_theme_color_override("font_color", Color(0, 0, 0, 1))
				submit.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
				submit.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
				submit.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
				submit.add_theme_stylebox_override("normal", btn_normal)
				submit.add_theme_stylebox_override("hover", btn_hover)
				submit.add_theme_stylebox_override("pressed", btn_pressed)
				submit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

			if not option_node.resized.is_connected(_on_option_resized):
				option_node.resized.connect(_on_option_resized)

		# Right side: Model (Database Specs) (Width = 240)
		var model_node = inspector.get_node_or_null("Model") as Control
		if model_node:
			model_node.position = Vector2(595, 45)
			model_node.size = Vector2(240, 560)
			
			# Compact and space fields cleanly inside Model to prevent text overlap
			var fields = {
				"NameFieldLabel": 15,
				"NamePanel": 31,
				"ModelFieldLabel": 65,
				"ModelPanel": 81,
				"StatusFieldLabel": 115,
				"StatusPanel": 131,
				"ManuFieldLabel": 165,
				"ManuPanel": 181,
				"QuotaFieldLabel": 215,
				"QuotaPanel": 233,
				"DiagSpecsTitle": 275,
				"DiagSpecsDetails": 295
			}
			
			for f_name in fields.keys():
				var f_node = model_node.get_node_or_null(f_name) as Control
				if f_node:
					f_node.position.y = fields[f_name]
					f_node.position.x = 10
					if f_name.ends_with("Panel"):
						f_node.size.x = 220
					elif f_name == "DiagSpecsDetails":
						var lbl = f_node as Label
						if lbl:
							lbl.text = "INTEGRITY: NOMINAL\nEMPATHY: 98.4%\nTEMP: 37.4C (STABLE)\nOEC LINK: ONLINE\nLOCK: SECURE\n\n-----------------\nAPPARATUS OS v4.98\nSYSTEM READY."
							lbl.size = Vector2(220, 160)
						
		# Now re-register all child margins so dragging scales properly
		if inspector.has_method("register_child_margins"):
			inspector.register_child_margins()

	var crt = get_node_or_null("CRTOverlay")
	if crt:
		crt.add_to_group("CRTOverlays")
		crt.visible = GameStats.crt_effect_enabled

	robots = RobotFactory.create_robots()
	was_wifi_on = GameStats.wifi_on
	var input_submit_callable := Callable(self, "_on_question_input_submitted")
	if question_input and not question_input.text_submitted.is_connected(input_submit_callable):
		question_input.text_submitted.connect(input_submit_callable)

	var submit_button_callable := Callable(self, "_on_submit_question_button_pressed")
	if submit_question_button and not submit_question_button.pressed.is_connected(submit_button_callable):
		submit_question_button.pressed.connect(submit_button_callable)
	
	_setup_question_popup()
	var dropdown_callable := Callable(self, "_on_chat_button1_pressed")
	if chat_button1 and not chat_button1.pressed.is_connected(dropdown_callable):
		chat_button1.pressed.connect(dropdown_callable)
		
	spawn_next_robot()
	if health_bar:
		if "breaches" in health_bar:
			health_bar.breaches = GameStats.total_security_breaches
		health_bar.value = GameStats.player_health

	# Handle Day 1 Database offline panel
	var current_day = day_manager.current_day
	var database_panel = get_node_or_null("ApparatusInspectorWindow/Model")
	if database_panel:
		if current_day == 1:
			# Hide all sub-controls of Model except InfoPanel
			for child in database_panel.get_children():
				if child.name != "InfoPanel":
					child.visible = false
			
			# Create/ensure offline placeholder label
			var offline_label = database_panel.get_node_or_null("OfflineLabel") as Label
			if not offline_label:
				offline_label = Label.new()
				offline_label.name = "OfflineLabel"
				offline_label.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
				offline_label.add_theme_font_size_override("font_size", 14)
				offline_label.add_theme_color_override("font_color", Color(0.8, 0, 0, 1)) # red text
				offline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				offline_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				offline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				offline_label.text = "\n\nDATABASE OFFLINE\n-----------------\nShift 1:\nCalibration Mode\n\nNo telemetry data\navailable.\n\nInspect via dialogue\ntells only."
				
				# Position label cleanly inside InfoPanel
				offline_label.set_anchors_preset(Control.PRESET_FULL_RECT)
				offline_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
				offline_label.grow_vertical = Control.GROW_DIRECTION_BOTH
				offline_label.offset_left = 15
				offline_label.offset_top = 15
				offline_label.offset_right = -15
				offline_label.offset_bottom = -15
				database_panel.add_child(offline_label)
			offline_label.visible = true
		else:
			# Restore all sub-controls of Model to visible
			for child in database_panel.get_children():
				if child.name != "OfflineLabel":
					child.visible = true
			var offline_label = database_panel.get_node_or_null("OfflineLabel")
			if offline_label:
				offline_label.visible = false

	# Show Scribble tutorial assistant automatically on shift start
	var scribble = get_node_or_null("ScribbleWindow")
	if scribble:
		scribble.visible = true
		if scribble.has_method("move_to_front"):
			scribble.move_to_front()

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
		chat_manager.add_message(current_robot.get_greeting(), current_robot.name)
		
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
		
func pick_next_robot() -> RobotData:
	if day_manager.current_day == 1 and day_manager.processed_today == 2:
		current_robot = RobotFactory.create_walter_robot()
		return current_robot

	if robots.is_empty():
		current_robot = null
		return null

	var index := randi_range(0, robots.size() - 1)
	current_robot = robots[index]
	robots.remove_at(index)

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
	
	refresh_question_buttons()

func handle_last_terminal_chat():
	if not is_inside_tree() or not chat_manager:
		return
	if final_message == false:
		chat_manager.add_message("Inspectation complete. Please issue your final judgment for this AI.", "Terminal: ")
		final_message = true

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

func _on_good_button_pressed() -> void:
	if is_processing_choice:
		return
	is_processing_choice = true
	print("Button Pressed: GOOD (Pass)")
	if current_robot:
		if (current_robot.name == "Walter" or current_robot.model == "H.U.G.O") and day_manager.current_day == 1:
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
		if (current_robot.name == "Walter" or current_robot.model == "H.U.G.O") and day_manager.current_day == 1:
			trigger_walter_escape()
			return
		day_manager.process_robot(current_robot, false)
		current_robot = null
		spawn_next_robot()
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(0.25).timeout
		is_processing_choice = false

func _unhandled_input(event: InputEvent) -> void:
	if question_dropdown_panel and question_dropdown_panel.visible:
		if event is InputEventMouseButton and event.pressed:
			var mouse_pos := question_dropdown_panel.get_global_mouse_position()
			var in_panel := question_dropdown_panel.get_global_rect().has_point(mouse_pos)
			var in_btn := (chat_button1 != null and chat_button1.get_global_rect().has_point(mouse_pos))
			if not in_panel and not in_btn:
				question_dropdown_panel.visible = false

func _on_chat_button1_pressed() -> void:
	if current_robot == null or is_waiting_for_replay:
		return
	if question_dropdown_panel == null:
		_setup_question_popup()
	if question_dropdown_panel:
		question_dropdown_panel.visible = not question_dropdown_panel.visible
		if question_dropdown_panel.visible:
			_update_dropdown_panel_position()
			question_dropdown_panel.move_to_front()

func _on_chat_button2_pressed() -> void:
	pass

func _setup_question_popup() -> void:
	var option_node := get_node_or_null("ApparatusInspectorWindow/Option") as Control
	if not option_node:
		return
		
	if option_node.has_node("QuestionDropdownPanel"):
		question_dropdown_panel = option_node.get_node("QuestionDropdownPanel") as NinePatchRect
		return

	question_dropdown_panel = NinePatchRect.new()
	question_dropdown_panel.name = "QuestionDropdownPanel"
	question_dropdown_panel.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	question_dropdown_panel.patch_margin_left = 10
	question_dropdown_panel.patch_margin_top = 10
	question_dropdown_panel.patch_margin_right = 10
	question_dropdown_panel.patch_margin_bottom = 10
	question_dropdown_panel.z_index = 15
	question_dropdown_panel.visible = false
	option_node.add_child(question_dropdown_panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 6
	vbox.offset_top = 6
	vbox.offset_right = -6
	vbox.offset_bottom = -6
	vbox.add_theme_constant_override("separation", 4)
	question_dropdown_panel.add_child(vbox)

	var questions := [
		"State your primary purpose.",
		"What do you think of humans?",
		"Do you understand why you are being inspected?"
	]

	var font_bold := preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var btn_normal := preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover := preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed := preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")

	for q_text in questions:
		var btn := Button.new()
		btn.text = q_text
		btn.custom_minimum_size = Vector2(0, 34)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_OFF
		btn.clip_text = true
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.add_theme_font_override("font", font_bold)
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		btn.pressed.connect(func(): _on_dropdown_question_selected(q_text))
		vbox.add_child(btn)

	_update_dropdown_panel_position()

func _update_dropdown_panel_position() -> void:
	if question_dropdown_panel == null:
		return
	var option_node := get_node_or_null("ApparatusInspectorWindow/Option") as Control
	var btn1 := option_node.get_node_or_null("Button1") as Button if option_node else null
	if btn1:
		var panel_w: float = btn1.size.x
		var panel_h: float = 3.0 * 34.0 + 2.0 * 4.0 + 12.0 # 122.0
		question_dropdown_panel.position = Vector2(btn1.position.x, btn1.position.y - panel_h - 4.0)
		question_dropdown_panel.size = Vector2(panel_w, panel_h)

func _on_dropdown_question_selected(q_text: String) -> void:
	if question_dropdown_panel:
		question_dropdown_panel.visible = false
	if chat_button1:
		chat_button1.text = "▲  " + q_text
	submit_question_text(q_text)

func _on_question_input_submitted(text: String) -> void:
	submit_question_text(text)
	
func _on_submit_question_button_pressed() -> void:
	submit_question_text(question_input.text)

func submit_question_text(text: String) -> void:
	if current_robot == null:
		return

	if is_waiting_for_replay:
		return

	var cleaned_text := text.strip_edges()

	if cleaned_text.is_empty():
		refocus_question_input()
		return

	question_input.clear()

	var robot_reply := current_robot.get_response_for_typed_question(cleaned_text)

	if robot_reply.is_empty():
		chat_manager.add_message(cleaned_text, "You")
		chat_manager.add_message("QUERY NOT RECOGNIZED.", "Terminal")
		refocus_question_input()
		return

	handle_chat_choice(cleaned_text, robot_reply)
	refocus_question_input()

func refocus_question_input() -> void:
	if question_input == null or not is_inside_tree():
		return
	question_input.grab_focus()
	question_input.caret_column = question_input.text.length()
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(0.12).timeout
	if question_input and is_inside_tree():
		question_input.grab_focus()
		question_input.caret_column = question_input.text.length()

func _on_option_resized() -> void:
	var option_node = get_node_or_null("ApparatusInspectorWindow/Option") as Control
	if not option_node:
		return
	var w = option_node.size.x
	var ans_panel = option_node.get_node_or_null("AnswerPanel") as Panel
	if ans_panel:
		ans_panel.size = option_node.size
	var btn1 = option_node.get_node_or_null("Button1") as Button
	if btn1:
		btn1.position = Vector2(10, 18)
		btn1.size = Vector2(max(50, w - 20), 38)
		btn1.autowrap_mode = TextServer.AUTOWRAP_OFF
		btn1.clip_text = true
		btn1.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var btn2 = option_node.get_node_or_null("Button2") as Button
	if btn2:
		btn2.visible = false
		btn2.disabled = true
	var submit = option_node.get_node_or_null("SubmitQuestionButton") as Button
	if submit:
		submit.position = Vector2(w - 10 - submit.size.x, 64)
	var input = option_node.get_node_or_null("QuestionInput") as LineEdit
	if input:
		input.position = Vector2(10, 64)
		input.size.x = max(50, w - 20 - 10 - (submit.size.x if submit else 45))
	
	_update_dropdown_panel_position()
	
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
	if chat_button1:
		chat_button1.text = "▲  No Robot Loaded"
		chat_button1.disabled = true

	if chat_button2:
		chat_button2.text = ""
		chat_button2.disabled = true
		chat_button2.visible = false

	if chat_button3:
		chat_button3.text = ""
		chat_button3.disabled = true
		chat_button3.visible = false

func refresh_question_buttons() -> void:
	if current_robot == null:
		clear_question_buttons()
		return
	
	if chat_button1:
		chat_button1.disabled = false
		chat_button1.visible = true
		chat_button1.text = "▲  Select Question..."

	if chat_button2:
		chat_button2.text = ""
		chat_button2.disabled = true
		chat_button2.visible = false

	if chat_button3:
		chat_button3.text = ""
		chat_button3.disabled = true
		chat_button3.visible = false
	
