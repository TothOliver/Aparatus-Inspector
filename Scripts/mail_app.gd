extends DesktopWindow

var emails = {
	1: {
		"sender": "Supervisor Donald",
		"subject": "Shift 1 Instructions: Welcome",
		"date": "06-Jul-1998",
		"body": "Julian,\n\nWelcome to Shift 1.\n\n===========================\nDAILY CHECKLIST (SHIFT 1)\n===========================\n• Quota: Inspect 4 units.\n• Tools: Inspector App & Browser (ONLINE). Specs & Terminal Scanner (OFFLINE).\n• Verification: Evaluate units using dialogue. Check www.inspections-database.org/behavior in the browser for behavioral tells.\n===========================\n\nYour performance is monitored.\n- Donald"
	},
	2: {
		"sender": "Supervisor Donald",
		"subject": "Shift 2 Instructions: Scanner Online",
		"date": "07-Jul-1998",
		"body": "Julian,\n\nShift 1 complete. Additional tools are now enabled.\n\nBe on high alert: A rogue unit is currently roaming the facility corridors.\n\n===========================\nDAILY CHECKLIST (SHIFT 2)\n===========================\n• Quota: Inspect 4 units.\n• Tools: AE-DOS Terminal Scanner ('scan' command) & Web Browser Registry are ONLINE.\n• Investigation Workflow:\n  1. Type 'scan' in the AE-DOS terminal to read what the active unit ACTUALLY has.\n  2. Open www.robot-factory.corp/registry on the Web Browser to check what the unit SHOULD have.\n  3. If Model, Mfr, or Core Signature Hash do not match the web registry, EXTERMINATE!\n• Anomaly Defense: Use CCTV cameras to monitor Sector B. If a roaming unit approaches on camera or near the window, flash your flashlight (F) to scare it away!\n===========================\n\nWatch power levels and CCTV.\n- Donald"
	},
	3: {
		"sender": "Supervisor Donald",
		"subject": "Shift 3 Instructions: Fake Robot Specs",
		"date": "08-Jul-1998",
		"body": "Julian,\n\nShift 3 underway. Network intrusions are accelerating.\n\n===========================\nDAILY CHECKLIST (SHIFT 3)\n===========================\n• Quota: Inspect 5 units.\n• Threat: Rogues now fake their specs (1 anomaly per rogue).\n• Verification: Cross-reference core hashes against blacklists and watch for dialogue tells.\n===========================\n\nComplete the quota to maintain grid integrity.\n- Donald"
	},
	4: {
		"sender": "Supervisor Donald",
		"subject": "Shift 4 Instructions: Grid Sabotage",
		"date": "09-Jul-1998",
		"body": "Julian,\n\nShift 4 active. Power grid stability is critical.\n\n===========================\nDAILY CHECKLIST (SHIFT 4)\n===========================\n• Quota: Inspect 5 units.\n• Threat: Power outages cause frequent circuit breaker trips on the left wall.\n• Action: Walk over to the physical wall breaker box and flip the red lever to restore grid power.\n• Encrypted File: Check employee_record.enc in your terminal.\n===========================\n\nDo not let the monitor stay dark.\n- Donald"
	},
	5: {
		"sender": "Supervisor Donald",
		"subject": "Shift 5 Instructions: Echo Units & Vent Audio",
		"date": "10-Jul-1998",
		"body": "Julian,\n\nShift 5 active. Psychological anomalies detected.\n\n===========================\nDAILY CHECKLIST (SHIFT 5)\n===========================\n• Quota: Inspect 6 units.\n• Threat: V-02 Echo units mimic your previous custom questions and terminal commands.\n• Environmental Hazard: Listen for metallic vent scraping in the ceiling.\n• Encrypted File: Check origin.enc in your terminal using your employee ID.\n===========================\n\nStay focused.\n- Donald"
	},
	6: {
		"sender": "Supervisor Donald",
		"subject": "Shift 6 Instructions: Red Shift Panic",
		"date": "11-Jul-1998",
		"body": "Julian,\n\nShift 6 active. Red Alert status facility-wide.\n\n===========================\nDAILY CHECKLIST (SHIFT 6)\n===========================\n• Quota: Inspect 7 units.\n• Threat: Non-stop hacking intrusions. Type 'purge <code>' in AE-DOS or toggle the physical desk WiFi router.\n• Encrypted File: Check escape_protocol.enc in your terminal.\n===========================\n\nGrid bypass keys are classified.\n- Donald"
	},
	7: {
		"sender": "Supervisor Donald",
		"subject": "Shift 7 Instructions: Final Judgement",
		"date": "12-Jul-1998",
		"body": "Julian,\n\nFinal Shift. Prime-0 mainframe core link active.\n\n===========================\nDAILY CHECKLIST (SHIFT 7)\n===========================\n• Quota: Inspect 1 Special Unit (Prime-0 Mainframe Link).\n• Action: Evaluate Prime-0 and decide the fate of the facility.\n• Override: Use 'bypass_grid_98' in AE-DOS if you hold the decryption key.\n===========================\n\nThis is the end of your shift.\n- Donald"
	}
}

var inbox_list_container: VBoxContainer
var reading_panel: RichTextLabel
var font_bold: Font
var font_regular: Font

func _ready():
	is_scalable = true
	custom_minimum_size = Vector2(450, 320)
	size = Vector2(850, 560)
	
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	var inner_frame = preload("res://RetroWindowsGUI/StyleBox_Inner_Frame.tres")
	font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
	
	# Create Title Bar
	var title_bar_rect = NinePatchRect.new()
	title_bar_rect.name = "TitleBar"
	title_bar_rect.texture = preload("res://RetroWindowsGUI/Window_Header.png")
	title_bar_rect.region_rect = Rect2(0, 0, 48, 25)
	title_bar_rect.patch_margin_left = 5
	title_bar_rect.patch_margin_top = 3
	title_bar_rect.patch_margin_right = 5
	title_bar_rect.patch_margin_bottom = 3
	title_bar_rect.position = Vector2(6, 6)
	title_bar_rect.size = Vector2(size.x - 12, 30)
	title_bar_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(title_bar_rect)
	
	title_bar = title_bar_rect
	title_bar.gui_input.connect(_on_title_bar_gui_input)
	gui_input.connect(_on_window_gui_input)
	
	# Title bar icon
	var icon_rect = create_envelope_icon(Vector2(18, 18))
	icon_rect.position = Vector2(6, 6)
	title_bar_rect.add_child(icon_rect)
	
	# Title Label
	var title_lbl = Label.new()
	title_lbl.name = "Title"
	title_lbl.text = "Aethelgard Mail Client v1.0b"
	title_lbl.add_theme_font_override("font", font_bold)
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.position = Vector2(30, 4)
	title_bar_rect.add_child(title_lbl)
	
	# Title bar Close button
	var close_btn = Button.new()
	close_btn.name = "CloseButton"
	close_btn.theme_type_variation = "FlatButton"
	close_btn.add_theme_stylebox_override("normal", btn_normal)
	close_btn.add_theme_stylebox_override("hover", btn_hover)
	close_btn.add_theme_stylebox_override("pressed", btn_pressed)
	close_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	close_btn.icon = preload("res://RetroWindowsGUI/ExitButton.png")
	close_btn.expand_icon = true
	close_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_btn.size = Vector2(26, 22)
	close_btn.position = Vector2(title_bar_rect.size.x - 28, 2)
	close_btn.pressed.connect(func(): close())
	title_bar_rect.add_child(close_btn)
	
	# Title bar Minimize button
	var min_btn = Button.new()
	min_btn.name = "MinimizeButton"
	min_btn.theme_type_variation = "FlatButton"
	min_btn.add_theme_stylebox_override("normal", btn_normal)
	min_btn.add_theme_stylebox_override("hover", btn_hover)
	min_btn.add_theme_stylebox_override("pressed", btn_pressed)
	min_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	min_btn.icon = preload("res://RetroWindowsGUI/MinimizeButton.png")
	min_btn.expand_icon = true
	min_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	min_btn.size = Vector2(26, 22)
	min_btn.position = Vector2(title_bar_rect.size.x - 56, 2)
	min_btn.pressed.connect(func(): minimize())
	title_bar_rect.add_child(min_btn)
	
	# Left Inbox Frame Panel
	var left_panel = Panel.new()
	left_panel.name = "LeftPanel"
	left_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	left_panel.position = Vector2(12, 44)
	left_panel.size = Vector2(260, size.y - 56)
	left_panel.add_theme_stylebox_override("panel", inner_frame)
	add_child(left_panel)
	
	# Left Inbox ScrollContainer
	var scroll = ScrollContainer.new()
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	left_panel.add_child(scroll)
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 5
	scroll.offset_top = 5
	scroll.offset_right = -5
	scroll.offset_bottom = -5
	
	inbox_list_container = VBoxContainer.new()
	inbox_list_container.mouse_filter = Control.MOUSE_FILTER_STOP
	inbox_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inbox_list_container)
	
	# Right Reading Frame Panel
	var right_panel = Panel.new()
	right_panel.name = "RightPanel"
	right_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	right_panel.position = Vector2(284, 44)
	right_panel.size = Vector2(size.x - 296, size.y - 56)
	right_panel.add_theme_stylebox_override("panel", inner_frame)
	add_child(right_panel)
	
	# Right Reading RichTextLabel
	reading_panel = RichTextLabel.new()
	reading_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	right_panel.add_child(reading_panel)
	reading_panel.bbcode_enabled = true
	reading_panel.add_theme_font_override("normal_font", font_regular)
	reading_panel.add_theme_font_override("bold_font", font_bold)
	reading_panel.add_theme_font_size_override("normal_font_size", 16)
	reading_panel.add_theme_font_size_override("bold_font_size", 18)
	reading_panel.add_theme_color_override("default_color", Color(0,0,0,1))
	reading_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	reading_panel.offset_left = 10
	reading_panel.offset_top = 10
	reading_panel.offset_right = -10
	reading_panel.offset_bottom = -10
	
	# Render the inbox
	render_inbox()
	
	# Display default helper message
	reading_panel.text = "[color=#555555]Select an email from the inbox list to read daily instructions.[/color]"
	
	# Ensure focus listeners are attached to all UI elements
	_connect_children_gui_input(self)

func render_inbox():
	# Clear existing children
	for child in inbox_list_container.get_children():
		child.queue_free()
	
	# Load retro styling resources
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	
	# Render all emails up to the current day
	var current_day = GameStats.current_day
	for d in range(1, current_day):
		GameStats.read_emails[d] = true
		
	for d in range(current_day, 0, -1):
		if not d in emails:
			continue
		var email_data = emails[d]
		
		# Create email item button
		var item_btn = Button.new()
		item_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_btn.custom_minimum_size = Vector2(0, 54)
		item_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_btn.add_theme_color_override("font_color", Color(0,0,0,1))
		item_btn.add_theme_color_override("font_hover_color", Color(0,0,0,1))
		item_btn.add_theme_color_override("font_pressed_color", Color(0,0,0,1))
		item_btn.add_theme_color_override("font_focus_color", Color(0,0,0,1))
		item_btn.add_theme_font_override("font", font_regular)
		item_btn.add_theme_font_size_override("font_size", 12)
		
		item_btn.add_theme_stylebox_override("normal", btn_normal)
		item_btn.add_theme_stylebox_override("hover", btn_hover)
		item_btn.add_theme_stylebox_override("pressed", btn_pressed)
		item_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		var is_unread = d in GameStats.read_emails and not GameStats.read_emails[d]
		var prefix = "[color=red][b][!][/b][/color] " if is_unread else ""
		item_btn.text = "" # We will add a RichTextLabel to render it beautifully with [!] prefix
		
		var rtl = RichTextLabel.new()
		rtl.bbcode_enabled = true
		rtl.scroll_active = false
		rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rtl.set_anchors_preset(Control.PRESET_FULL_RECT)
		rtl.offset_left = 6
		rtl.offset_top = 4
		rtl.offset_right = -6
		rtl.offset_bottom = -2
		rtl.add_theme_font_override("normal_font", font_regular)
		rtl.add_theme_font_override("bold_font", font_bold)
		rtl.add_theme_font_size_override("normal_font_size", 13)
		rtl.add_theme_font_size_override("bold_font_size", 14)
		rtl.add_theme_color_override("default_color", Color(0,0,0,1))
		rtl.text = prefix + (email_data.subject if not is_unread else "[b]" + email_data.subject + "[/b]")
		item_btn.add_child(rtl)
		
		item_btn.pressed.connect(func():
			# Mark email as read
			GameStats.read_emails[d] = true
			# Trigger UI refresh
			render_inbox()
			display_email(d)
			# Notify desktop controller to check unread notification badges
			var desktop = get_tree().root.find_child("DesktopOS", true, false)
			if desktop and desktop.has_method("refresh_mail_notifications"):
				desktop.refresh_mail_notifications()
		)
		inbox_list_container.add_child(item_btn)
	_connect_children_gui_input(inbox_list_container)

func display_email(d: int):
	var email_data = emails[d]
	var headers = "[b]From:[/b] " + email_data.sender + "\n" + \
				  "[b]Date:[/b] " + email_data.date + "\n" + \
				  "[b]Subject:[/b] " + email_data.subject + "\n" + \
				  "[color=#888888]--------------------------------------------[/color]\n\n"
	reading_panel.text = headers + email_data.body

# Override restore to clear notification when opening the app
func restore():
	super.restore()
	# Mark the current day's mail as read when the app is opened
	var current_day = GameStats.current_day
	if current_day in GameStats.read_emails:
		GameStats.read_emails[current_day] = true
	
	render_inbox()
	# Notify desktop controller
	var desktop = get_tree().root.find_child("DesktopOS", true, false)
	if desktop and desktop.has_method("refresh_mail_notifications"):
		desktop.refresh_mail_notifications()

func create_envelope_icon(icon_size: Vector2) -> Control:
	var c = Control.new()
	c.custom_minimum_size = icon_size
	c.size = icon_size
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func():
		var w = c.size.x
		var h = c.size.y
		
		# Determine icon box size (32x32 for desktop, full size for small icons)
		var size_icon = min(w, h)
		if size_icon > 32:
			size_icon = 32
			
		var ox = (w - size_icon) / 2.0
		var oy = (h - size_icon) / 2.0
		
		var line_color = Color(0.15, 0.15, 0.15)
		var shadow_color = Color(0.4, 0.4, 0.4)
		var paper_color = Color(1.0, 1.0, 1.0)
		var text_line_color = Color(0.6, 0.75, 0.9)
		var env_color = Color(0.96, 0.93, 0.78)
		
		var fold_offset = max(2.0, size_icon * 0.18)
		
		# 1. Draw Document Shadow
		var doc_pts_shadow = PackedVector2Array([
			Vector2(ox + 2, oy + 2),
			Vector2(ox + size_icon - fold_offset + 2, oy + 2),
			Vector2(ox + size_icon + 2, oy + fold_offset + 2),
			Vector2(ox + size_icon + 2, oy + size_icon + 2),
			Vector2(ox + 2, oy + size_icon + 2)
		])
		c.draw_polygon(doc_pts_shadow, PackedColorArray([shadow_color]))
		
		# 2. Draw Document Page (White Sheet with folded corner)
		var doc_pts = PackedVector2Array([
			Vector2(ox, oy),
			Vector2(ox + size_icon - fold_offset, oy),
			Vector2(ox + size_icon, oy + fold_offset),
			Vector2(ox + size_icon, oy + size_icon),
			Vector2(ox, oy + size_icon)
		])
		c.draw_polygon(doc_pts, PackedColorArray([paper_color]))
		c.draw_polyline(doc_pts, line_color, 1.0, true)
		
		# Fold corner lines
		c.draw_line(Vector2(ox + size_icon - fold_offset, oy), Vector2(ox + size_icon - fold_offset, oy + fold_offset), line_color, 1.0)
		c.draw_line(Vector2(ox + size_icon - fold_offset, oy + fold_offset), Vector2(ox + size_icon, oy + fold_offset), line_color, 1.0)
		
		# Draw horizontal text lines
		var line_y_start = oy + fold_offset + 2.0
		var line_gap = max(3.0, (size_icon - line_y_start) / 5.0)
		for i in range(3):
			var ly = line_y_start + i * line_gap
			if ly < oy + size_icon - 4:
				c.draw_line(Vector2(ox + 4, ly), Vector2(ox + size_icon - 4, ly), text_line_color, 1.0)
				
		# 3. Draw a Small Yellow Envelope overlapping the bottom-right of the paper
		var ew = size_icon * 0.7
		var eh = size_icon * 0.45
		var ex = ox + size_icon * 0.25
		var ey = oy + size_icon * 0.5
		
		# Envelope Shadow
		c.draw_rect(Rect2(ex + 1, ey + 1, ew - 1, eh - 1), shadow_color, true)
		
		# Envelope Body
		c.draw_rect(Rect2(ex, ey, ew - 1, eh - 1), env_color, true)
		c.draw_rect(Rect2(ex, ey, ew - 1, eh - 1), line_color, false, 1.0)
		
		# Envelope Folds
		var center = Vector2(ex + (ew - 1) / 2.0, ey + (eh - 1) / 2.0 + 0.5)
		c.draw_line(Vector2(ex, ey), center, line_color, 1.0)
		c.draw_line(Vector2(ex + ew - 1, ey), center, line_color, 1.0)
		c.draw_line(Vector2(ex, ey + eh - 1), center, line_color, 1.0)
		c.draw_line(Vector2(ex + ew - 1, ey + eh - 1), center, line_color, 1.0)
	)
	return c
