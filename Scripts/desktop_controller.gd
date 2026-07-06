extends Control
class_name DesktopController

@onready var inspector_window = %ApparatusInspectorWindow
@onready var notepad_window = %NotepadWindow
@onready var terminal_window = %TerminalWindow
@onready var minesweeper_window = %MinesweeperWindow
@onready var snake_window = %SnakeWindow
@onready var cctv_window = %CCTVWindow
@onready var slot_machine_window = %SlotMachineWindow
@onready var settings_window = %SettingsWindow

@onready var inspector_tab = %InspectorTab
@onready var notepad_tab = %NotepadTab
@onready var terminal_tab = %TerminalTab
@onready var minesweeper_tab = %MinesweeperTab
@onready var snake_tab = %SnakeTab
@onready var cctv_tab = %CCTVTab
@onready var slots_tab = %SlotsTab
@onready var settings_tab = %SettingsTab

@onready var cctv_texture = %CCTVTexture
@onready var power_bar = %PowerBar
@onready var hacker_alert = %HackerAlert

@onready var clock_label = %ClockLabel
@onready var start_menu = %StartMenu

var last_hack_active: bool = false
var hacker_alert_dismissed: bool = false
var active_window: Control = null
var browser_window: Control = null
var browser_tab: Button = null
var shift_verify_window: Control = null
var shift_verify_tab: Button = null
var mail_window: Control = null
var mail_tab: Button = null

func _ready():
	if start_menu:
		start_menu.z_index = 10
	var taskbar = get_node_or_null("Taskbar")
	if taskbar:
		taskbar.z_index = 9

	# Initially hide Notepad, Terminal, Minesweeper, Snake, CCTV, Slots, Inspector
	inspector_window.visible = false
	notepad_window.visible = false
	terminal_window.visible = false
	minesweeper_window.visible = false
	snake_window.visible = false
	cctv_window.visible = false
	slot_machine_window.visible = false
	settings_window.visible = false
	
	# Bind CCTV feed from 3D viewport at runtime
	var cctv_vp = get_node_or_null("/root/Game3D/CCTVViewport")
	if cctv_vp and cctv_texture:
		cctv_texture.texture = cctv_vp.get_texture()
	
	# Instantiate Browser Window
	var browser_script = preload("res://Scripts/browser.gd")
	browser_window = NinePatchRect.new()
	browser_window.name = "BrowserWindow"
	browser_window.set_script(browser_script)
	browser_window.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	browser_window.patch_margin_left = 12
	browser_window.patch_margin_top = 12
	browser_window.patch_margin_right = 12
	browser_window.patch_margin_bottom = 12
	browser_window.position = Vector2(250, 150)
	get_parent().call_deferred("add_child", browser_window)
	browser_window.visible = false

	# Instantiate Shift Verify Window (Disabled)
	# var shift_verify_scene = preload("res://Scenes/ShiftVerifyWindow.tscn")
	# shift_verify_window = shift_verify_scene.instantiate()
	# get_parent().call_deferred("add_child", shift_verify_window)
	# shift_verify_window.visible = false

	# Instantiate Browser Tab Button
	var active_tabs_container = get_node_or_null("Taskbar/ActiveTabs")
	browser_tab = Button.new()
	browser_tab.name = "BrowserTab"
	browser_tab.custom_minimum_size = Vector2(40, 0)
	browser_tab.icon = load("res://Sprites/icon_browser.png")
	browser_tab.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	browser_tab.expand_icon = true
	browser_tab.pressed.connect(func():
		toggle_window_from_tab("Browser")
	)
	if active_tabs_container:
		active_tabs_container.add_child(browser_tab)

	# Instantiate Mail Window
	var mail_script = preload("res://Scripts/mail_app.gd")
	mail_window = NinePatchRect.new()
	mail_window.name = "MailWindow"
	mail_window.set_script(mail_script)
	mail_window.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	mail_window.patch_margin_left = 12
	mail_window.patch_margin_top = 12
	mail_window.patch_margin_right = 12
	mail_window.patch_margin_bottom = 12
	mail_window.position = Vector2(300, 120)
	get_parent().call_deferred("add_child", mail_window)
	mail_window.visible = false

	# Instantiate Mail Tab Button
	mail_tab = Button.new()
	mail_tab.name = "MailTab"
	mail_tab.custom_minimum_size = Vector2(40, 0)
	mail_tab.pressed.connect(func():
		toggle_window_from_tab("Mail")
	)
	if active_tabs_container:
		active_tabs_container.add_child(mail_tab)
	
	var tab_icon = create_envelope_icon(Vector2(20, 15))
	tab_icon.set_anchors_preset(Control.PRESET_CENTER)
	tab_icon.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tab_icon.grow_vertical = Control.GROW_DIRECTION_BOTH
	mail_tab.add_child(tab_icon)

	# Taskbar notification badge for Mail
	var tab_badge = Panel.new()
	tab_badge.name = "TabNotificationBadge"
	var tab_badge_style = StyleBoxFlat.new()
	tab_badge_style.bg_color = Color(0.8, 0, 0, 1)
	tab_badge_style.set_corner_radius_all(6)
	tab_badge.add_theme_stylebox_override("panel", tab_badge_style)
	tab_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	tab_badge.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tab_badge.grow_vertical = Control.GROW_DIRECTION_BOTH
	tab_badge.offset_left = -16
	tab_badge.offset_top = 4
	tab_badge.offset_right = -4
	tab_badge.offset_bottom = 16
	mail_tab.add_child(tab_badge)

	# Instantiate Shift Verify Tab Button (Disabled)
	# shift_verify_tab = Button.new()
	# shift_verify_tab.name = "ShiftVerifyTab"
	# shift_verify_tab.custom_minimum_size = Vector2(40, 0)
	# shift_verify_tab.icon = load("res://Sprites/icon_shift_verify.png")
	# shift_verify_tab.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# shift_verify_tab.expand_icon = true
	# shift_verify_tab.pressed.connect(func():
	# 	toggle_window_from_tab("ShiftVerify")
	# )
	# if active_tabs_container:
	# 	active_tabs_container.add_child(shift_verify_tab)

	# Dynamic Browser Desktop Shortcut
	var desktop_icons_container = get_node_or_null("DesktopIcons")
	if desktop_icons_container:
		var browser_icon_btn = Button.new()
		browser_icon_btn.name = "BrowserIcon"
		browser_icon_btn.layout_mode = 0
		browser_icon_btn.position = Vector2(160, 30)
		browser_icon_btn.size = Vector2(110, 90)
		browser_icon_btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		
		var other_btn = desktop_icons_container.get_node_or_null("InspectorIcon") as Button
		if other_btn:
			browser_icon_btn.add_theme_stylebox_override("hover", other_btn.get_theme_stylebox("hover"))
			browser_icon_btn.add_theme_stylebox_override("pressed", other_btn.get_theme_stylebox("pressed"))
			browser_icon_btn.add_theme_stylebox_override("focus", other_btn.get_theme_stylebox("focus"))
		
		var vbox = VBoxContainer.new()
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		browser_icon_btn.add_child(vbox)
		
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(0, 48)
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.texture = load("res://Sprites/icon_browser.png")
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(icon_rect)
		
		var label = Label.new()
		label.text = "Apparatus\nExplorer"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color(1,1,1,1))
		label.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_constant_override("line_spacing", -4)
		vbox.add_child(label)
		
		browser_icon_btn.pressed.connect(func():
			open_app("Browser")
		)
		desktop_icons_container.add_child(browser_icon_btn)

		# Dynamic Mail Desktop Shortcut
		var mail_icon_btn = Button.new()
		mail_icon_btn.name = "MailIcon"
		mail_icon_btn.layout_mode = 0
		mail_icon_btn.position = Vector2(160, 150)
		mail_icon_btn.size = Vector2(110, 90)
		mail_icon_btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		if other_btn:
			mail_icon_btn.add_theme_stylebox_override("hover", other_btn.get_theme_stylebox("hover"))
			mail_icon_btn.add_theme_stylebox_override("pressed", other_btn.get_theme_stylebox("pressed"))
			mail_icon_btn.add_theme_stylebox_override("focus", other_btn.get_theme_stylebox("focus"))
		
		var mail_vbox = VBoxContainer.new()
		mail_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mail_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mail_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		mail_vbox.add_theme_constant_override("separation", 2)
		mail_icon_btn.add_child(mail_vbox)
		
		var mail_icon_rect = create_envelope_icon(Vector2(48, 48))
		mail_vbox.add_child(mail_icon_rect)
		
		var mail_lbl = Label.new()
		mail_lbl.text = "Inbox Mail"
		mail_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mail_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		mail_lbl.add_theme_color_override("font_color", Color(1,1,1,1))
		mail_lbl.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
		mail_lbl.add_theme_font_size_override("font_size", 12)
		mail_vbox.add_child(mail_lbl)
		
		mail_icon_btn.pressed.connect(func():
			open_app("Mail")
		)
		desktop_icons_container.add_child(mail_icon_btn)
		
		# Create the notification badge on desktop icon envelope
		var mail_notification_badge = Panel.new()
		mail_notification_badge.name = "NotificationBadge"
		mail_notification_badge.size = Vector2(14, 14)
		mail_notification_badge.position = Vector2(32, 4)
		
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(0.8, 0, 0, 1)
		badge_style.set_corner_radius_all(7)
		mail_notification_badge.add_theme_stylebox_override("panel", badge_style)
		
		var badge_label = Label.new()
		badge_label.text = "!"
		badge_label.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
		badge_label.add_theme_font_size_override("font_size", 9)
		badge_label.add_theme_color_override("font_color", Color(1,1,1,1))
		badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		mail_notification_badge.add_child(badge_label)
		
		mail_icon_rect.add_child(mail_notification_badge)
		
		# Initial refresh of notifications
		call_deferred("refresh_mail_notifications")

	# Dynamic Shift Verify Desktop Shortcut (Disabled)
	# if desktop_icons_container:
	# 	var verify_icon_btn = Button.new()
	# 	verify_icon_btn.name = "ShiftVerifyIcon"
	# 	verify_icon_btn.layout_mode = 0
	# 	verify_icon_btn.position = Vector2(160, 150)
	# 	verify_icon_btn.size = Vector2(110, 90)
	# 	verify_icon_btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	# 	
	# 	var other_btn = desktop_icons_container.get_node_or_null("InspectorIcon") as Button
	# 	if other_btn:
	# 		verify_icon_btn.add_theme_stylebox_override("hover", other_btn.get_theme_stylebox("hover"))
	# 		verify_icon_btn.add_theme_stylebox_override("pressed", other_btn.get_theme_stylebox("pressed"))
	# 		verify_icon_btn.add_theme_stylebox_override("focus", other_btn.get_theme_stylebox("focus"))
	# 	
	# 	var vbox = VBoxContainer.new()
	# 	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# 	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# 	vbox.add_theme_constant_override("separation", 2)
	# 	verify_icon_btn.add_child(vbox)
	# 	
	# 	var icon_rect = TextureRect.new()
	# 	icon_rect.custom_minimum_size = Vector2(0, 48)
	# 	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 	icon_rect.texture = load("res://Sprites/icon_shift_verify.png")
	# 	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# 	vbox.add_child(icon_rect)
	# 	
	# 	var label = Label.new()
	# 	label.text = "Shift\nVerify"
	# 	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# 	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# 	label.add_theme_color_override("font_color", Color(1,1,1,1))
	# 	label.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
	# 	label.add_theme_font_size_override("font_size", 12)
	# 	label.add_theme_constant_override("line_spacing", -4)
	# 	vbox.add_child(label)
	# 	
	# 	verify_icon_btn.pressed.connect(func():
	# 		open_app("ShiftVerify")
	# 	)
	# 	desktop_icons_container.add_child(verify_icon_btn)

	# Dynamic Browser Start Menu Button
	var program_list = get_node_or_null("StartMenu/HBox/ProgramList")
	if program_list:
		var browser_btn = Button.new()
		browser_btn.name = "BrowserBtn"
		browser_btn.text = " Apparatus Explorer"
		browser_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		browser_btn.custom_minimum_size = Vector2(0, 36)
		browser_btn.add_theme_color_override("font_color", Color(0,0,0,1))
		browser_btn.add_theme_color_override("font_hover_color", Color(1,1,1,1))
		browser_btn.add_theme_color_override("font_focus_color", Color(1,1,1,1))
		browser_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
		browser_btn.add_theme_font_size_override("font_size", 12)
		
		var ref_btn = program_list.get_node_or_null("InspectorBtn") as Button
		if ref_btn:
			browser_btn.add_theme_stylebox_override("normal", ref_btn.get_theme_stylebox("normal"))
			browser_btn.add_theme_stylebox_override("hover", ref_btn.get_theme_stylebox("hover"))
			browser_btn.add_theme_stylebox_override("focus", ref_btn.get_theme_stylebox("focus"))
		
		browser_btn.icon = load("res://Sprites/icon_browser.png")
		browser_btn.expand_icon = true
		browser_btn.pressed.connect(func():
			_on_start_menu_app_selected("Browser")
		)
		program_list.add_child(browser_btn)
		var divider_node = program_list.get_node_or_null("Divider")
		if divider_node:
			program_list.move_child(browser_btn, divider_node.get_index())

		# Dynamic Mail Start Menu Button
		var mail_btn = Button.new()
		mail_btn.name = "MailBtn"
		mail_btn.text = "      Inbox Mail"
		mail_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		mail_btn.custom_minimum_size = Vector2(0, 36)
		mail_btn.add_theme_color_override("font_color", Color(0,0,0,1))
		mail_btn.add_theme_color_override("font_hover_color", Color(1,1,1,1))
		mail_btn.add_theme_color_override("font_focus_color", Color(1,1,1,1))
		mail_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
		mail_btn.add_theme_font_size_override("font_size", 12)
		
		if ref_btn:
			mail_btn.add_theme_stylebox_override("normal", ref_btn.get_theme_stylebox("normal"))
			mail_btn.add_theme_stylebox_override("hover", ref_btn.get_theme_stylebox("hover"))
			mail_btn.add_theme_stylebox_override("focus", ref_btn.get_theme_stylebox("focus"))
		
		var start_menu_icon = create_envelope_icon(Vector2(20, 15))
		start_menu_icon.position = Vector2(8, 10)
		mail_btn.add_child(start_menu_icon)
		
		mail_btn.pressed.connect(func():
			_on_start_menu_app_selected("Mail")
		)
		program_list.add_child(mail_btn)
		if divider_node:
			program_list.move_child(mail_btn, divider_node.get_index())

	# Dynamic Shift Verify Start Menu Button (Disabled)
	# if program_list:
	# 	var verify_btn = Button.new()
	# 	verify_btn.name = "ShiftVerifyBtn"
	# 	verify_btn.text = " Shift Verify"
	# 	verify_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	# 	verify_btn.custom_minimum_size = Vector2(0, 36)
	# 	verify_btn.add_theme_color_override("font_color", Color(0,0,0,1))
	# 	verify_btn.add_theme_color_override("font_hover_color", Color(1,1,1,1))
	# 	verify_btn.add_theme_color_override("font_focus_color", Color(1,1,1,1))
	# 	verify_btn.add_theme_font_override("font", preload("res://RetroWindowsGUI/M 8pt.ttf"))
	# 	verify_btn.add_theme_font_size_override("font_size", 12)
	# 	
	# 	var ref_btn = program_list.get_node_or_null("InspectorBtn") as Button
	# 	if ref_btn:
	# 		verify_btn.add_theme_stylebox_override("normal", ref_btn.get_theme_stylebox("normal"))
	# 		verify_btn.add_theme_stylebox_override("hover", ref_btn.get_theme_stylebox("hover"))
	# 		verify_btn.add_theme_stylebox_override("focus", ref_btn.get_theme_stylebox("focus"))
	# 	
	# 	verify_btn.icon = load("res://Sprites/icon_shift_verify.png")
	# 	verify_btn.expand_icon = true
	# 	verify_btn.pressed.connect(func():
	# 		_on_start_menu_app_selected("ShiftVerify")
	# 	)
	# 	program_list.add_child(verify_btn)
	# 	var divider_node = program_list.get_node_or_null("Divider")
	# 	if divider_node:
	# 		program_list.move_child(verify_btn, divider_node.get_index())
	
	# Connect window signals to update taskbar tabs and focus state
	var apps = [
		[inspector_window, inspector_tab],
		[notepad_window, notepad_tab],
		[terminal_window, terminal_tab],
		[minesweeper_window, minesweeper_tab],
		[snake_window, snake_tab],
		[cctv_window, cctv_tab],
		[slot_machine_window, slots_tab],
		[settings_window, settings_tab]
	]
	if browser_window and browser_tab:
		apps.append([browser_window, browser_tab])
	if shift_verify_window and shift_verify_tab:
		apps.append([shift_verify_window, shift_verify_tab])
		
	for app in apps:
		var window = app[0]
		var tab = app[1]
		window.closed.connect(func(): 
			_update_tab_state(tab, false)
			_update_top_window_focus()
		)
		window.minimized.connect(func(): 
			_update_tab_state(tab, false)
			_update_top_window_focus()
		)
		window.focused.connect(func():
			_update_top_window_focus()
		)
	
	# Initialize tab focus states
	_update_top_window_focus()
	
	_adjust_start_menu_height()
	
	# Close start menu initially
	if start_menu:
		start_menu.visible = false
		
	# Automatically focus and raise window if a child control inside it gains focus
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)

func _adjust_start_menu_height():
	if not start_menu:
		return
	var program_list = start_menu.get_node_or_null("HBox/ProgramList") as VBoxContainer
	if not program_list:
		return
	
	if is_inside_tree():
		await get_tree().process_frame
		
	var list_height = program_list.get_combined_minimum_size().y
	var new_height = list_height + 8 # Top/bottom margins of HBox inside NinePatchRect
	var bottom_y = 970.0 # Standard Y coordinate right above taskbar top edge
	
	start_menu.size.y = new_height
	start_menu.position.y = bottom_y - new_height

func _process(_delta):
	# Update clock time
	if clock_label:
		var time = Time.get_time_dict_from_system()
		clock_label.text = "%02d:%02d" % [time.hour, time.minute]
		
	# Update power bar UI
	if power_bar:
		power_bar.value = GameStats.power_level
		
	# Update Wifi Status UI
	var wifi_status = get_node_or_null("%WifiStatus") as TextureRect
	if wifi_status:
		if GameStats.wifi_on:
			wifi_status.texture = preload("res://Sprites/wifi_on.png")
		else:
			wifi_status.texture = preload("res://Sprites/wifi_off.png")
		
	# Manage hacker alert visibility
	if hacker_alert:
		if GameStats.hack_active:
			if not last_hack_active:
				hacker_alert_dismissed = false
			
			if not hacker_alert_dismissed:
				if not hacker_alert.visible:
					hacker_alert.visible = true
					hacker_alert.move_to_front()
			else:
				hacker_alert.visible = false
		else:
			hacker_alert.visible = false
			hacker_alert_dismissed = false
		
		last_hack_active = GameStats.hack_active

func _update_tab_state(tab: Button, active: bool):
	if tab:
		var normal_style = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
		var hover_style = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
		var pressed_style = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
		
		var app_name = tab.name.replace("Tab", "")
		tab.text = ""
		
		# Ensure font colors are black for legibility
		tab.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		tab.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		tab.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		tab.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))

		
		if active:
			tab.visible = true
			tab.add_theme_stylebox_override("normal", pressed_style)
			tab.add_theme_stylebox_override("hover", pressed_style)
			tab.add_theme_stylebox_override("pressed", pressed_style)
			tab.add_theme_stylebox_override("focus", pressed_style)
		else:
			var window = _get_window_by_name(app_name)
			if window and window.visible:
				tab.visible = true
			else:
				# Keep tab visible for quick restore from taskbar
				tab.visible = true
			
			tab.add_theme_stylebox_override("normal", normal_style)
			tab.add_theme_stylebox_override("hover", hover_style)
			tab.add_theme_stylebox_override("pressed", pressed_style)
			tab.add_theme_stylebox_override("focus", hover_style)

func _get_window_by_name(window_name: String) -> Control:
	match window_name:
		"Inspector": return inspector_window
		"Notepad": return notepad_window
		"Terminal": return terminal_window
		"Minesweeper": return minesweeper_window
		"Snake": return snake_window
		"CCTV": return cctv_window
		"Slots": return slot_machine_window
		"Settings": return settings_window
		"Browser": return browser_window
		"ShiftVerify": return shift_verify_window
		"Mail": return mail_window
	return null

func shutdown_computer():
	if start_menu:
		start_menu.visible = false
	var game_3d = get_node_or_null("/root/Game3D")
	if game_3d and game_3d.is_monitor_on:
		game_3d.toggle_monitor_power()

# Triggered by double-clicking or clicking desktop icons
func open_app(app_name: String):
	var window = _get_window_by_name(app_name)
	if window:
		window.restore()

func toggle_window_from_tab(app_name: String):
	var window = _get_window_by_name(app_name)
	if window:
		if window.visible:
			window.minimize()
		else:
			window.restore()

func _get_tab_by_name(tab_name: String) -> Button:
	match tab_name:
		"Inspector": return inspector_tab
		"Notepad": return notepad_tab
		"Terminal": return terminal_tab
		"Minesweeper": return minesweeper_tab
		"Snake": return snake_tab
		"CCTV": return cctv_tab
		"Slots": return slots_tab
		"Settings": return settings_tab
		"Browser": return browser_tab
		"ShiftVerify": return shift_verify_tab
		"Mail": return mail_tab
	return null

func _on_start_button_pressed():
	if start_menu:
		start_menu.visible = not start_menu.visible
		if start_menu.visible:
			start_menu.move_to_front()

func _on_start_menu_app_selected(app_name: String):
	open_app(app_name)
	if start_menu:
		start_menu.visible = false

func _update_top_window_focus():
	var top_window_name = ""
	var highest_index = -1
	var top_window_node = null
	
	for app_name in ["Inspector", "Notepad", "Terminal", "Minesweeper", "Snake", "CCTV", "Slots", "Settings", "Browser", "Mail"]:
		var window = _get_window_by_name(app_name)
		if window and window.visible:
			var idx = window.get_index()
			if idx > highest_index:
				highest_index = idx
				top_window_name = app_name
				top_window_node = window
				
	active_window = top_window_node
	_update_window_focus_visuals(top_window_name)
	
	for app_name in ["Inspector", "Notepad", "Terminal", "Minesweeper", "Snake", "CCTV", "Slots", "Settings", "Browser", "Mail"]:
		var tab = _get_tab_by_name(app_name)
		_update_tab_state(tab, app_name == top_window_name)

func _update_window_focus_visuals(active_app_name: String):
	var active_header = preload("res://RetroWindowsGUI/Window_Header.png")
	var inactive_header = preload("res://RetroWindowsGUI/Window_Header_Inactive.png")
	
	for app_name in ["Inspector", "Notepad", "Terminal", "Minesweeper", "Snake", "CCTV", "Slots", "Settings", "Browser", "Mail"]:
		var window = _get_window_by_name(app_name)
		if window:
			var title_bar = window.get_node_or_null("TitleBar") as NinePatchRect
			if title_bar:
				var title_label = title_bar.get_node_or_null("Title") as Label
				if app_name == active_app_name:
					title_bar.texture = active_header
					if title_label:
						title_label.add_theme_color_override("font_color", Color(1, 1, 1, 1)) # White
				else:
					title_bar.texture = inactive_header
					if title_label:
						title_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1)) # Light Grey

func _on_hacker_alert_terminal_pressed():
	hacker_alert_dismissed = true
	if hacker_alert:
		hacker_alert.visible = false
	open_app("Terminal")

func _on_gui_focus_changed(control: Control):
	if not control:
		return
	var p = control.get_parent()
	while p and p != get_viewport():
		if p.has_method("restore"):
			if p.visible and active_window != p:
				p.move_to_front()
				p.focused.emit()
			break
		p = p.get_parent()

func _on_cam1_pressed():
	var cam1 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera1")
	var cam2 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera2")
	var cam3 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera3")
	if cam1:
		cam1.current = true
	if cam2:
		cam2.current = false
	if cam3:
		cam3.current = false
	var label = get_node_or_null("%CCTVWindow/CameraControls/CameraLabel")
	if label:
		label.text = "Camera: Corridor"

func _on_cam2_pressed():
	var cam1 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera1")
	var cam2 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera2")
	var cam3 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera3")
	if cam1:
		cam1.current = false
	if cam2:
		cam2.current = true
	if cam3:
		cam3.current = false
	var label = get_node_or_null("%CCTVWindow/CameraControls/CameraLabel")
	if label:
		label.text = "Camera: Room 2"

func _on_cam3_pressed():
	var cam1 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera1")
	var cam2 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera2")
	var cam3 = get_node_or_null("/root/Game3D/CCTVViewport/CCTVCamera3")
	if cam1:
		cam1.current = false
	if cam2:
		cam2.current = false
	if cam3:
		cam3.current = true
	var label = get_node_or_null("%CCTVWindow/CameraControls/CameraLabel")
	if label:
		label.text = "Camera: Room 3"

func refresh_mail_notifications():
	var has_unread = GameStats.has_unread_mail()
	
	# Update desktop icon badge
	var desktop_icons = get_node_or_null("DesktopIcons")
	if desktop_icons:
		var icon_btn = desktop_icons.get_node_or_null("MailIcon")
		if icon_btn:
			var badge = icon_btn.find_child("NotificationBadge", true, false)
			if badge:
				badge.visible = has_unread
				
	# Update taskbar tab badge
	if mail_tab:
		var tab_badge = mail_tab.find_child("TabNotificationBadge", true, false)
		if tab_badge:
			tab_badge.visible = has_unread

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
