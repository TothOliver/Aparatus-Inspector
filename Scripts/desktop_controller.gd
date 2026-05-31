extends Control
class_name DesktopController

@onready var inspector_window = %AparatusInspectorWindow
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

func _ready():
	# Initially hide Notepad, Terminal, Minesweeper, Snake, CCTV, Slots; show Inspector
	inspector_window.visible = true
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
	
	# Connect window signals to update taskbar tabs and focus state
	for app in [
		[inspector_window, inspector_tab],
		[notepad_window, notepad_tab],
		[terminal_window, terminal_tab],
		[minesweeper_window, minesweeper_tab],
		[snake_window, snake_tab],
		[cctv_window, cctv_tab],
		[slot_machine_window, slots_tab],
		[settings_window, settings_tab]
	]:
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
	
	# Close start menu initially
	if start_menu:
		start_menu.visible = false
		
	# Automatically focus and raise window if a child control inside it gains focus
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)

func _process(_delta):
	# Update clock time
	if clock_label:
		var time = Time.get_time_dict_from_system()
		clock_label.text = "%02d:%02d" % [time.hour, time.minute]
		
	# Update power bar UI
	if power_bar:
		power_bar.value = GameStats.power_level
		
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
		tab.text = app_name
		
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

func _get_window_by_name(name: String) -> Control:
	match name:
		"Inspector": return inspector_window
		"Notepad": return notepad_window
		"Terminal": return terminal_window
		"Minesweeper": return minesweeper_window
		"Snake": return snake_window
		"CCTV": return cctv_window
		"Slots": return slot_machine_window
		"Settings": return settings_window
	return null

# Triggered by double-clicking or clicking desktop icons
func open_app(app_name: String):
	var window = _get_window_by_name(app_name)
	if window:
		window.restore()

# Triggered by clicking taskbar tabs
func toggle_window_from_tab(app_name: String):
	var window = _get_window_by_name(app_name)
	var tab = _get_tab_by_name(app_name)
	if window:
		# If the window is currently visible and is at the top of the viewport z-order, minimize it
		if window.visible and window.get_index() == window.get_parent().get_child_count() - 1:
			window.minimize()
		else:
			# Otherwise, restore and focus it
			window.restore()

func _get_tab_by_name(name: String) -> Button:
	match name:
		"Inspector": return inspector_tab
		"Notepad": return notepad_tab
		"Terminal": return terminal_tab
		"Minesweeper": return minesweeper_tab
		"Snake": return snake_tab
		"CCTV": return cctv_tab
		"Slots": return slots_tab
		"Settings": return settings_tab
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
	
	for app_name in ["Inspector", "Notepad", "Terminal", "Minesweeper", "Snake", "CCTV", "Slots", "Settings"]:
		var window = _get_window_by_name(app_name)
		if window and window.visible:
			var idx = window.get_index()
			if idx > highest_index:
				highest_index = idx
				top_window_name = app_name
				top_window_node = window
				
	active_window = top_window_node
	_update_window_focus_visuals(top_window_name)
	
	for app_name in ["Inspector", "Notepad", "Terminal", "Minesweeper", "Snake", "CCTV", "Slots", "Settings"]:
		var tab = _get_tab_by_name(app_name)
		_update_tab_state(tab, app_name == top_window_name)

func _update_window_focus_visuals(active_app_name: String):
	var active_header = preload("res://RetroWindowsGUI/Window_Header.png")
	var inactive_header = preload("res://RetroWindowsGUI/Window_Header_Inactive.png")
	
	for app_name in ["Inspector", "Notepad", "Terminal", "Minesweeper", "Snake", "CCTV", "Slots", "Settings"]:
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
