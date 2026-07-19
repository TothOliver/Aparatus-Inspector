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

func _ready():
	# Resize and reposition ApparatusInspectorWindow to be smaller (920x660 instead of 1060x800) and scalable
	var inspector = get_node_or_null("ApparatusInspectorWindow") as NinePatchRect
	if inspector:
		inspector.custom_minimum_size = Vector2(850, 620)
		inspector.size = Vector2(920, 660)
		inspector.position = Vector2(200, 50)
		
		var title_bar_node = inspector.get_node_or_null("TitleBar") as Control
		if title_bar_node:
			title_bar_node.size.x = 908
			var close_btn = title_bar_node.get_node_or_null("CloseButton") as Button
			if close_btn:
				close_btn.position.x = 883
		
		# Compact left side: Picture stays Y=45, H=280.
		# AcceptTerminate panel starts at Y=335, H=310.
		var accept_term = inspector.get_node_or_null("AcceptTerminate") as Control
		if accept_term:
			accept_term.position.y = 335
			accept_term.size = Vector2(250, 310)
			
			var app_info = accept_term.get_node_or_null("ApproveInfo") as Label
			if app_info:
				app_info.text = "APPROVE:\nPass to grid service."
				app_info.position = Vector2(15, 40)
				app_info.size = Vector2(220, 36)
				
			var good_btn = accept_term.get_node_or_null("ButtonPanel/GoodButton") as Button
			if good_btn:
				good_btn.position = Vector2(15, 88)
				good_btn.size = Vector2(220, 50)
				
			var ext_info = accept_term.get_node_or_null("ExterminateInfo") as Label
			if ext_info:
				ext_info.text = "EXTERMINATE:\nFlag for disposal."
				ext_info.position = Vector2(15, 167)
				ext_info.size = Vector2(220, 36)
				
			var bad_btn = accept_term.get_node_or_null("ButtonPanel/BadButton") as Button
			if bad_btn:
				bad_btn.position = Vector2(15, 217)
				bad_btn.size = Vector2(220, 50)

		# Compact middle side: ChatManager and Option
		var chat_manager_node = inspector.get_node_or_null("ChatManager") as Control
		if chat_manager_node:
			chat_manager_node.position.y = 45
			chat_manager_node.size = Vector2(385, 380) # H=380 instead of 460
			
		var option_node = inspector.get_node_or_null("Option") as Control
		if option_node:
			option_node.position.y = 440 # starts immediately after ChatManager
			option_node.size = Vector2(385, 205) # H=205 instead of 235
			
			var btn1 = option_node.get_node_or_null("Button1") as Button
			if btn1:
				btn1.position = Vector2(15, 20)
				btn1.size = Vector2(355, 75)
				btn1.anchor_right = 1.0
				btn1.offset_right = -15
				
			var btn2 = option_node.get_node_or_null("Button2") as Button
			if btn2:
				btn2.position = Vector2(15, 110)
				btn2.size = Vector2(355, 75)
				btn2.anchor_right = 1.0
				btn2.offset_right = -15

		# Compact right side: Model (Database Specs)
		var model_node = inspector.get_node_or_null("Model") as Control
		if model_node:
			model_node.position = Vector2(664, 45) # X=664, aligned to right
			model_node.size = Vector2(244, 600)
			
			# Compact the fields inside Model
			var fields = {
				"NameFieldLabel": 15,
				"NamePanel": 31,
				"ModelFieldLabel": 70,
				"ModelPanel": 86,
				"StatusFieldLabel": 125,
				"StatusPanel": 141,
				"ManuFieldLabel": 180,
				"ManuPanel": 196,
				"QuotaFieldLabel": 235,
				"QuotaPanel": 251,
				"DiagSpecsTitle": 310,
				"DiagSpecsDetails": 330
			}
			
			for f_name in fields.keys():
				var f_node = model_node.get_node_or_null(f_name) as Control
				if f_node:
					f_node.position.y = fields[f_name]
					if f_name == "DiagSpecsDetails":
						var lbl = f_node as Label
						if lbl:
							lbl.text = "INTEGRITY: NOMINAL\nEMPATHY: 98.4%\nTEMP: 37.4C (STABLE)\nOEC LINK: ONLINE\nLOCK: SECURE\n\n-----------------\nAPPARATUS OS v4.98\nSYSTEM READY."
							lbl.size = Vector2(220, 180)
						
		# Now re-register all child margins so dragging scales properly
		if inspector.has_method("register_child_margins"):
			inspector.register_child_margins()

	var crt = get_node_or_null("CRTOverlay")
	if crt:
		crt.add_to_group("CRTOverlays")
	robots = RobotFactory.create_robots()
	was_wifi_on = GameStats.wifi_on
	spawn_next_robot()
	health_bar.value = GameStats.player_health
	sanity_bar.value = GameStats.player_sanity

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

	# Show Scribble tutorial assistant automatically on Day 1 start
	if day_manager.current_day == 1:
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
		chat_button1.text = ""
		chat_button2.text = ""
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
	
	if chat_manager.chatCount == 6:
		chat_button1.text = ""
		chat_button2.text = ""
		if not is_inside_tree() or not get_tree():
			return
		await get_tree().create_timer(0.3).timeout
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
