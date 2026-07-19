extends Control

@onready var crt_checkbox = $CRTCheckbox
@onready var volume_slider = $VolumeSlider
@onready var volume_value_label = $VolumeValueLabel
@onready var sensitivity_slider = $SensitivitySlider
@onready var sensitivity_value_label = $SensitivityValueLabel
@onready var quit_button = get_node_or_null("QuitButton")

var is_pause_menu: bool = false
var was_visible: bool = false
var opened_frame: int = -1

# Tab layout variables
var current_tab: String = "General"
var general_tab_btn: Button
var controls_tab_btn: Button
var general_container: Control
var controls_container: Control

# Rebinding variables
var listening_action: String = ""
var listening_button: Button = null
var keybind_buttons: Dictionary = {}

const ACTION_LABELS = {
	"move_forward": "Move Forward",
	"move_backward": "Move Backward",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"crouch": "Crouch",
	"interact": "Interact",
	"toggle_flashlight": "Flashlight"
}

func _ready():
	# If parent is PauseWindow, dynamically add a CRTOverlay covering the full PauseMenu.
	var pause_window = get_parent()
	if pause_window and pause_window.name == "PauseWindow":
		is_pause_menu = true
		var pause_menu = pause_window.get_parent()
		if pause_menu and pause_menu.name == "PauseMenu":
			pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
			
			var crt = ColorRect.new()
			crt.name = "PauseCRTOverlay"
			crt.mouse_filter = Control.MOUSE_FILTER_IGNORE
			crt.set_anchors_preset(Control.PRESET_FULL_RECT)
			crt.anchor_left = 0
			crt.anchor_top = 0
			crt.anchor_right = 1
			crt.anchor_bottom = 1
			crt.offset_left = 0
			crt.offset_top = 0
			crt.offset_right = 0
			crt.offset_bottom = 0
			
			var crt_shader = preload("res://crt_filter.gdshader")
			var mat = ShaderMaterial.new()
			mat.shader = crt_shader
			mat.set_shader_parameter("scanline_count", 320.0)
			mat.set_shader_parameter("scanline_intensity", 0.08)
			mat.set_shader_parameter("curvature", 0.025)
			mat.set_shader_parameter("vignette_intensity", 0.08)
			mat.set_shader_parameter("grr_intensity", 0.03)
			mat.set_shader_parameter("aberration", 0.001)
			crt.material = mat
			crt.z_index = 20
			
			# Add as a child of PauseMenu so it draws over everything full-screen without squashing
			pause_menu.add_child.call_deferred(crt)
			crt.add_to_group("CRTOverlays")
			crt.visible = GameStats.crt_effect_enabled

	# Load retro assets
	var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	var inner_frame = preload("res://RetroWindowsGUI/StyleBox_Inner_Frame.tres")

	# Dynamic resize and positioning of parent settings window
	var parent = get_parent()
	if parent and parent is Control:
		parent.size = Vector2(450, 490)
		var viewport_size = get_viewport_rect().size
		parent.position.x = (viewport_size.x - 450) / 2.0
		
		# Update TitleBar
		var title_bar = parent.get_node_or_null("TitleBar")
		if title_bar:
			title_bar.size.x = 450 - 12
			var close_button = title_bar.get_node_or_null("CloseButton")
			if close_button:
				close_button.position.x = title_bar.size.x - 26

	# Resize self (SettingsBody) to fill parent
	self.size = Vector2(426, 436)
	if "offset_right" in self:
		self.offset_right = 438
	if "offset_bottom" in self:
		self.offset_bottom = 478

	# Position QuitButton down if it exists
	if quit_button:
		quit_button.position = Vector2(153, 400)

	# Create General Container
	general_container = Control.new()
	general_container.name = "GeneralContainer"
	general_container.position = Vector2.ZERO
	general_container.size = Vector2(426, 380)
	add_child(general_container)

	# Reparent original settings nodes to general_container and shift them down by 45px explicitly to avoid overlaps
	var nodes_to_reparent = [
		get_node_or_null("DisplayGroup"),
		get_node_or_null("DisplayGroupLabel"),
		get_node_or_null("CRTCheckbox"),
		get_node_or_null("AudioGroup"),
		get_node_or_null("AudioGroupLabel"),
		get_node_or_null("VolumeLabel"),
		get_node_or_null("VolumeValueLabel"),
		get_node_or_null("VolumeSlider"),
		get_node_or_null("MouseGroup"),
		get_node_or_null("MouseGroupLabel"),
		get_node_or_null("SensitivityLabel"),
		get_node_or_null("SensitivityValueLabel"),
		get_node_or_null("SensitivitySlider")
	]
	
	for n in nodes_to_reparent:
		if n:
			n.reparent(general_container, false)
			n.position.y += 45

	# Create Controls Container
	controls_container = Control.new()
	controls_container.name = "ControlsContainer"
	controls_container.position = Vector2.ZERO
	controls_container.size = Vector2(426, 380)
	add_child(controls_container)

	# Create Controls Group Panel inside Controls Container (shifted down by 55px to match GeneralContainer)
	var controls_group = Panel.new()
	controls_group.name = "ControlsGroup"
	controls_group.position = Vector2(10, 55)
	controls_group.size = Vector2(406, 330)
	controls_group.add_theme_stylebox_override("panel", inner_frame)
	controls_container.add_child(controls_group)

	# Create Controls Group Label
	var controls_label = Label.new()
	controls_label.name = "ControlsGroupLabel"
	controls_label.position = Vector2(20, 47)
	controls_label.size = Vector2(130, 16)
	controls_label.text = "Keyboard Controls"
	controls_label.add_theme_font_override("font", font_regular)
	controls_label.add_theme_font_size_override("font_size", 12)
	controls_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))

	var style_lbl = StyleBoxFlat.new()
	style_lbl.bg_color = Color(0.83137, 0.81568, 0.78431, 1)
	style_lbl.expand_margin_left = 4.0
	style_lbl.expand_margin_right = 4.0
	controls_label.add_theme_stylebox_override("normal", style_lbl)
	controls_container.add_child(controls_label)

	# Add binding rows to Controls Group
	var idx = 0
	for action in ACTION_LABELS.keys():
		var row_label = Label.new()
		row_label.text = ACTION_LABELS[action]
		row_label.add_theme_font_override("font", font_regular)
		row_label.add_theme_font_size_override("font_size", 12)
		row_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		row_label.position = Vector2(20, 25 + idx * 38)
		row_label.size = Vector2(160, 25)
		row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		controls_group.add_child(row_label)
		
		var row_btn = Button.new()
		row_btn.add_theme_font_override("font", font_bold)
		row_btn.add_theme_font_size_override("font_size", 12)
		row_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		row_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		row_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		row_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
		row_btn.add_theme_stylebox_override("normal", btn_normal)
		row_btn.add_theme_stylebox_override("hover", btn_hover)
		row_btn.add_theme_stylebox_override("pressed", btn_pressed)
		row_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		row_btn.position = Vector2(240, 22 + idx * 38)
		row_btn.size = Vector2(140, 26)
		
		row_btn.pressed.connect(func(): _on_keybind_button_pressed(action, row_btn))
		
		controls_group.add_child(row_btn)
		keybind_buttons[action] = row_btn
		idx += 1

	# Reset Defaults Button inside Controls Group
	var reset_btn = Button.new()
	reset_btn.text = "Reset Defaults"
	reset_btn.add_theme_font_override("font", font_bold)
	reset_btn.add_theme_font_size_override("font_size", 12)
	reset_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	reset_btn.add_theme_stylebox_override("normal", btn_normal)
	reset_btn.add_theme_stylebox_override("hover", btn_hover)
	reset_btn.add_theme_stylebox_override("pressed", btn_pressed)
	reset_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	reset_btn.position = Vector2(105, 290)
	reset_btn.size = Vector2(196, 28)
	reset_btn.pressed.connect(_on_reset_keybinds_pressed)
	controls_group.add_child(reset_btn)

	# Tab button: General Settings
	general_tab_btn = Button.new()
	general_tab_btn.text = "General Settings"
	general_tab_btn.add_theme_font_override("font", font_bold)
	general_tab_btn.add_theme_font_size_override("font_size", 12)
	general_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	general_tab_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	general_tab_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	general_tab_btn.position = Vector2(10, 10)
	general_tab_btn.size = Vector2(140, 25)
	general_tab_btn.pressed.connect(func(): _on_tab_changed("General"))
	add_child(general_tab_btn)

	# Tab button: Controls
	controls_tab_btn = Button.new()
	controls_tab_btn.text = "Controls"
	controls_tab_btn.add_theme_font_override("font", font_bold)
	controls_tab_btn.add_theme_font_size_override("font_size", 12)
	controls_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	controls_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	controls_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
	controls_tab_btn.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
	controls_tab_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	controls_tab_btn.position = Vector2(155, 10)
	controls_tab_btn.size = Vector2(100, 25)
	controls_tab_btn.pressed.connect(func(): _on_tab_changed("Controls"))
	add_child(controls_tab_btn)

	# Connect visibility signals & initialize tabs
	visibility_changed.connect(update_ui_from_stats)
	update_ui_from_stats()
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	if is_pause_menu:
		# Divert TitleBar CloseButton (x) to unpause the tree
		var close_button = get_node_or_null("../TitleBar/CloseButton")
		if close_button:
			for conn in close_button.pressed.get_connections():
				close_button.pressed.disconnect(conn.callable)
			close_button.pressed.connect(_on_resume_pressed)

func _process(_delta):
	if not is_pause_menu:
		return
		
	# Visibility change check to prevent double-triggering input in the same frame
	var pause_menu = get_node_or_null("../..")
	if pause_menu and pause_menu.name == "PauseMenu":
		if pause_menu.visible and not was_visible:
			opened_frame = Engine.get_process_frames()
		was_visible = pause_menu.visible

func _on_resume_pressed():
	if not is_pause_menu:
		return
		
	var pause_menu = get_node_or_null("../..")
	if pause_menu and pause_menu.name == "PauseMenu":
		pause_menu.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if not is_inside_tree():
		return
		
	# Process key rebinding input if listening
	if listening_action != "":
		if event is InputEventKey and event.pressed and not event.echo:
			var new_keycode = event.keycode
			if new_keycode == KEY_ESCAPE:
				listening_action = ""
				listening_button = null
				_update_keybind_buttons()
				get_viewport().set_input_as_handled()
				return
				
			# Swap if already bound to another action
			for act in GameStats.DEFAULT_BINDS.keys():
				if act != listening_action:
					var current_key = GameStats.custom_keybinds.get(act, GameStats.DEFAULT_BINDS[act])
					if current_key == new_keycode:
						var old_key = GameStats.custom_keybinds.get(listening_action, GameStats.DEFAULT_BINDS[listening_action])
						GameStats.custom_keybinds[act] = old_key
						break
						
			GameStats.custom_keybinds[listening_action] = new_keycode
			GameStats.save_settings()
			GameStats.setup_input_map()
			
			listening_action = ""
			listening_button = null
			_update_keybind_buttons()
			get_viewport().set_input_as_handled()
			return

	if not is_pause_menu:
		return
		
	var pause_menu = get_node_or_null("../..")
	if pause_menu and pause_menu.name == "PauseMenu" and pause_menu.visible:
		# Prevent unpausing in the same frame the menu is opened
		if Engine.get_process_frames() == opened_frame:
			return
			
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE)):
			get_viewport().set_input_as_handled()
			_on_resume_pressed()

func update_ui_from_stats():
	listening_action = ""
	listening_button = null
	current_tab = "General"
	_update_tab_visuals()
	_update_keybind_buttons()

	if crt_checkbox:
		if crt_checkbox.toggled.is_connected(_on_crt_toggled):
			crt_checkbox.toggled.disconnect(_on_crt_toggled)
		crt_checkbox.button_pressed = GameStats.crt_effect_enabled
		crt_checkbox.toggled.connect(_on_crt_toggled)
		_on_crt_toggled(GameStats.crt_effect_enabled)

	if volume_slider:
		if volume_slider.value_changed.is_connected(_on_volume_changed):
			volume_slider.value_changed.disconnect(_on_volume_changed)
		volume_slider.value = GameStats.master_volume
		volume_slider.value_changed.connect(_on_volume_changed)
		_on_volume_changed(GameStats.master_volume)

	if sensitivity_slider:
		if sensitivity_slider.value_changed.is_connected(_on_sensitivity_changed):
			sensitivity_slider.value_changed.disconnect(_on_sensitivity_changed)
		var t = (GameStats.mouse_sensitivity - 0.02) / (0.5 - 0.02)
		sensitivity_slider.value = clamp(t * 100.0, 0.0, 100.0)
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_on_sensitivity_changed(sensitivity_slider.value)

func _on_crt_toggled(toggled_on: bool):
	GameStats.crt_effect_enabled = toggled_on
	GameStats.save_settings()
	if is_inside_tree():
		for crt in get_tree().get_nodes_in_group("CRTOverlays"):
			crt.visible = toggled_on

func _on_volume_changed(value: float):
	GameStats.master_volume = value
	GameStats.save_settings()
	if volume_value_label:
		volume_value_label.text = str(int(round(value))) + "%"
	
	var bus_idx = AudioServer.get_bus_index("Master")
	if value <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		# Convert 0..100 linear value to decibels (-40 dB to 0 dB range)
		var db = -40.0 * (1.0 - (value / 100.0))
		if value <= 5.0:
			db = -80.0
		AudioServer.set_bus_volume_db(bus_idx, db)

func _on_sensitivity_changed(value: float):
	# Map slider 0..100 to sensitivity range 0.02 to 0.5
	var sens = 0.02 + (value / 100.0) * (0.5 - 0.02)
	GameStats.mouse_sensitivity = sens
	GameStats.save_settings()
	if sensitivity_value_label:
		sensitivity_value_label.text = "%.2f" % sens

func _on_quit_pressed():
	var parent = get_parent()
	if not parent:
		GameStats.quit_or_menu(get_tree())
		return
		
	var parent_size = parent.size if parent.size != Vector2.ZERO else Vector2(450, 460)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.4)
	overlay.size = parent_size
	overlay.position = Vector2.ZERO
	parent.add_child(overlay)
	
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

func _on_tab_changed(tab_name: String):
	current_tab = tab_name
	_update_tab_visuals()

func _update_tab_visuals():
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")

	if current_tab == "General":
		# General Settings is selected: raised white/light-grey (btn_hover)
		general_tab_btn.add_theme_stylebox_override("normal", btn_hover)
		general_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		general_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		general_tab_btn.add_theme_font_override("font", font_bold)
		general_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		# Controls is unselected: raised silver (btn_normal)
		controls_tab_btn.add_theme_stylebox_override("normal", btn_normal)
		controls_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		controls_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		controls_tab_btn.add_theme_font_override("font", font_regular)
		controls_tab_btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
		controls_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		controls_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		general_container.visible = true
		controls_container.visible = false
	else:
		# General Settings is unselected: raised silver (btn_normal)
		general_tab_btn.add_theme_stylebox_override("normal", btn_normal)
		general_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		general_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		general_tab_btn.add_theme_font_override("font", font_regular)
		general_tab_btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
		general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		# Controls is selected: raised white/light-grey (btn_hover)
		controls_tab_btn.add_theme_stylebox_override("normal", btn_hover)
		controls_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		controls_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		controls_tab_btn.add_theme_font_override("font", font_bold)
		controls_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		controls_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		controls_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
		general_container.visible = false
		controls_container.visible = true
		
		listening_action = ""
		listening_button = null
		_update_keybind_buttons()

func _update_keybind_buttons():
	for action in keybind_buttons.keys():
		var btn = keybind_buttons[action]
		if listening_action == action:
			btn.text = "[ Press Key ]"
		else:
			var keycode = GameStats.custom_keybinds.get(action, GameStats.DEFAULT_BINDS[action])
			var key_name = OS.get_keycode_string(keycode)
			btn.text = key_name

func _on_keybind_button_pressed(action: String, btn: Button):
	if listening_action == action:
		return
		
	if listening_action != "":
		listening_action = ""
		_update_keybind_buttons()
		
	listening_action = action
	listening_button = btn
	btn.text = "[ Press Key ]"
	btn.release_focus()

func _on_reset_keybinds_pressed():
	GameStats.custom_keybinds.clear()
	GameStats.save_settings()
	GameStats.setup_input_map()
	listening_action = ""
	listening_button = null
	_update_keybind_buttons()
