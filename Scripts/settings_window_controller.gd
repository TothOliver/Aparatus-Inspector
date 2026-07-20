extends Control

@onready var display_mode_option = get_node_or_null("GeneralContainer/DisplayModeOption")
@onready var resolution_option = get_node_or_null("GeneralContainer/ResolutionOption")
@onready var fps_option = get_node_or_null("GeneralContainer/FPSOption")
@onready var vsync_checkbox = get_node_or_null("GeneralContainer/VSyncCheckbox")
@onready var crt_checkbox = get_node_or_null("GeneralContainer/CRTCheckbox")

@onready var volume_slider = get_node_or_null("GeneralContainer/VolumeSlider")
@onready var volume_value_label = get_node_or_null("GeneralContainer/VolumeValueLabel")
@onready var music_volume_slider = get_node_or_null("GeneralContainer/MusicVolumeSlider")
@onready var music_volume_value_label = get_node_or_null("GeneralContainer/MusicVolumeValueLabel")
@onready var vfx_volume_slider = get_node_or_null("GeneralContainer/VfxVolumeSlider")
@onready var vfx_volume_value_label = get_node_or_null("GeneralContainer/VfxVolumeValueLabel")
@onready var ambient_volume_slider = get_node_or_null("GeneralContainer/AmbientVolumeSlider")
@onready var ambient_volume_value_label = get_node_or_null("GeneralContainer/AmbientVolumeValueLabel")

@onready var sensitivity_slider = get_node_or_null("GeneralContainer/SensitivitySlider")
@onready var sensitivity_value_label = get_node_or_null("GeneralContainer/SensitivityValueLabel")
@onready var quit_button = get_node_or_null("QuitButton")

@onready var general_tab_btn = $GeneralTabBtn
@onready var controls_tab_btn = $ControlsTabBtn
@onready var general_container = $GeneralContainer
@onready var controls_container = $ControlsContainer
@onready var controls_group = $ControlsContainer/ControlsGroup
@onready var controls_label = $ControlsContainer/ControlsGroupLabel

var is_pause_menu: bool = false
var was_visible: bool = false
var opened_frame: int = -1

# Tab layout variables
var current_tab: String = "General"

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

var available_resolutions: Array[Vector2i] = []
var available_fps_limits: Array[int] = []

const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

const FPS_LIMITS = [30, 60, 144, 165, 240, 0]

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

	# Dynamic resize and positioning of parent settings window
	var parent = get_parent()
	if parent and parent is Control:
		parent.size = Vector2(450, 790)
		var viewport_size = get_viewport_rect().size
		parent.position.x = (viewport_size.x - 450) / 2.0
		parent.position.y = max(10.0, (viewport_size.y - 790) / 2.0)
		
		# Update TitleBar
		var title_bar = parent.get_node_or_null("TitleBar")
		if title_bar:
			title_bar.size.x = 450 - 12
			var close_button = title_bar.get_node_or_null("CloseButton")
			if close_button:
				close_button.position.x = title_bar.size.x - 26

	# Resize self (SettingsBody) to fill parent
	self.size = Vector2(426, 750)
	if "offset_right" in self:
		self.offset_right = 438
	if "offset_bottom" in self:
		self.offset_bottom = 780

	# Position QuitButton down if it exists
	if quit_button:
		quit_button.position = Vector2(153, 700)

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

	# Configure tab buttons pressed callbacks
	general_tab_btn.pressed.connect(func(): _on_tab_changed("General"))
	controls_tab_btn.pressed.connect(func(): _on_tab_changed("Controls"))

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

	# Apply Windows 98 PopupMenu styling to option buttons
	style_retro_option_button(display_mode_option)
	style_retro_option_button(resolution_option)
	style_retro_option_button(fps_option)

	# Display Mode Option
	if display_mode_option:
		if display_mode_option.item_selected.is_connected(_on_display_mode_selected):
			display_mode_option.item_selected.disconnect(_on_display_mode_selected)
		display_mode_option.clear()
		display_mode_option.add_item("Windowed")
		display_mode_option.add_item("Borderless")
		display_mode_option.add_item("Fullscreen")
		display_mode_option.selected = clamp(GameStats.display_mode, 0, 2)
		display_mode_option.item_selected.connect(_on_display_mode_selected)

	# Resolution Option
	if resolution_option:
		if resolution_option.item_selected.is_connected(_on_resolution_selected):
			resolution_option.item_selected.disconnect(_on_resolution_selected)
		resolution_option.clear()

		available_resolutions.clear()
		for res in RESOLUTIONS:
			available_resolutions.append(res)

		var current_res = Vector2i(GameStats.resolution_width, GameStats.resolution_height)
		if not (current_res in available_resolutions):
			available_resolutions.append(current_res)
			available_resolutions.sort_custom(func(a, b): return (a.x * a.y) < (b.x * b.y))

		var selected_idx = 0
		for i in range(available_resolutions.size()):
			var res = available_resolutions[i]
			resolution_option.add_item("%d x %d" % [res.x, res.y])
			if res == current_res:
				selected_idx = i
		resolution_option.selected = selected_idx
		resolution_option.item_selected.connect(_on_resolution_selected)

	# FPS Option
	if fps_option:
		if fps_option.item_selected.is_connected(_on_fps_selected):
			fps_option.item_selected.disconnect(_on_fps_selected)
		fps_option.clear()

		available_fps_limits.clear()
		for limit in FPS_LIMITS:
			available_fps_limits.append(limit)

		if not (GameStats.fps_limit in available_fps_limits):
			available_fps_limits.append(GameStats.fps_limit)
			var zero_present = 0 in available_fps_limits
			if zero_present:
				available_fps_limits.erase(0)
			available_fps_limits.sort()
			if zero_present:
				available_fps_limits.append(0)

		var selected_fps_idx = available_fps_limits.size() - 1
		for i in range(available_fps_limits.size()):
			var limit = available_fps_limits[i]
			if limit == 0:
				fps_option.add_item("Unlimited")
			else:
				fps_option.add_item("%d FPS" % limit)
			if limit == GameStats.fps_limit:
				selected_fps_idx = i
		fps_option.selected = selected_fps_idx
		fps_option.item_selected.connect(_on_fps_selected)

	# VSync Checkbox
	if vsync_checkbox:
		if vsync_checkbox.toggled.is_connected(_on_vsync_toggled):
			vsync_checkbox.toggled.disconnect(_on_vsync_toggled)
		vsync_checkbox.button_pressed = GameStats.vsync_enabled
		vsync_checkbox.toggled.connect(_on_vsync_toggled)

	# CRT Checkbox
	if crt_checkbox:
		if crt_checkbox.toggled.is_connected(_on_crt_toggled):
			crt_checkbox.toggled.disconnect(_on_crt_toggled)
		crt_checkbox.button_pressed = GameStats.crt_effect_enabled
		crt_checkbox.toggled.connect(_on_crt_toggled)

	# Main Volume Slider
	_setup_volume_slider(volume_slider, volume_value_label, GameStats.master_volume, func(v): _on_volume_changed("Master", v))
	
	# Music Volume Slider
	_setup_volume_slider(music_volume_slider, music_volume_value_label, GameStats.music_volume, func(v): _on_volume_changed("Music", v))

	# VFX Volume Slider
	_setup_volume_slider(vfx_volume_slider, vfx_volume_value_label, GameStats.vfx_volume, func(v): _on_volume_changed("VFX", v))

	# Ambient Volume Slider
	_setup_volume_slider(ambient_volume_slider, ambient_volume_value_label, GameStats.ambient_volume, func(v): _on_volume_changed("Ambient", v))

	# Sensitivity Slider
	if sensitivity_slider:
		if sensitivity_slider.value_changed.is_connected(_on_sensitivity_changed):
			sensitivity_slider.value_changed.disconnect(_on_sensitivity_changed)
		var t = (GameStats.mouse_sensitivity - 0.02) / (0.5 - 0.02)
		sensitivity_slider.value = clamp(t * 100.0, 0.0, 100.0)
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_on_sensitivity_changed(sensitivity_slider.value)

func _setup_volume_slider(slider: HSlider, label: Label, initial_value: float, callback: Callable):
	if slider:
		for conn in slider.value_changed.get_connections():
			slider.value_changed.disconnect(conn.callable)
		slider.value = initial_value
		slider.value_changed.connect(callback)
		if label:
			label.text = str(int(round(initial_value))) + "%"

func _on_display_mode_selected(index: int):
	GameStats.display_mode = index
	GameStats.apply_all_settings()
	GameStats.save_settings()

func _on_resolution_selected(index: int):
	if index >= 0 and index < available_resolutions.size():
		var res = available_resolutions[index]
		GameStats.resolution_width = res.x
		GameStats.resolution_height = res.y
		GameStats.apply_all_settings()
		GameStats.save_settings()

func _on_fps_selected(index: int):
	if index >= 0 and index < available_fps_limits.size():
		GameStats.fps_limit = available_fps_limits[index]
		GameStats.apply_all_settings()
		GameStats.save_settings()

func _on_vsync_toggled(toggled_on: bool):
	GameStats.vsync_enabled = toggled_on
	GameStats.apply_all_settings()
	GameStats.save_settings()

func _on_crt_toggled(toggled_on: bool):
	GameStats.crt_effect_enabled = toggled_on
	GameStats.save_settings()
	GameStats.update_crt_overlays()

func _on_volume_changed(bus_name: String, value: float):
	if bus_name == "Master":
		GameStats.master_volume = value
		if volume_value_label:
			volume_value_label.text = str(int(round(value))) + "%"
	elif bus_name == "Music":
		GameStats.music_volume = value
		if music_volume_value_label:
			music_volume_value_label.text = str(int(round(value))) + "%"
	elif bus_name == "VFX":
		GameStats.vfx_volume = value
		if vfx_volume_value_label:
			vfx_volume_value_label.text = str(int(round(value))) + "%"
	elif bus_name == "Ambient":
		GameStats.ambient_volume = value
		if ambient_volume_value_label:
			ambient_volume_value_label.text = str(int(round(value))) + "%"
			
	GameStats.apply_bus_volume(bus_name, value)
	GameStats.save_settings()

func _on_sensitivity_changed(value: float):
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
		general_tab_btn.add_theme_stylebox_override("normal", btn_hover)
		general_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		general_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		general_tab_btn.add_theme_font_override("font", font_bold)
		general_tab_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
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
		general_tab_btn.add_theme_stylebox_override("normal", btn_normal)
		general_tab_btn.add_theme_stylebox_override("hover", btn_hover)
		general_tab_btn.add_theme_stylebox_override("pressed", btn_pressed)
		general_tab_btn.add_theme_font_override("font", font_regular)
		general_tab_btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
		general_tab_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		general_tab_btn.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		
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

func style_retro_option_button(btn: OptionButton):
	if not btn:
		return
	
	var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")

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

	var popup = btn.get_popup()
	if popup:
		popup.add_theme_font_override("font", font_regular)
		popup.add_theme_font_size_override("font_size", 12)
		popup.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		popup.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
		popup.add_theme_color_override("font_accelerator_color", Color(0.3, 0.3, 0.3, 1))
		popup.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5, 1))
		popup.add_theme_color_override("font_separator_color", Color(0, 0, 0, 1))
		
		# Windows 98 3D Panel border stylebox for dropdown popup
		var panel_sb = StyleBoxFlat.new()
		panel_sb.bg_color = Color(0.83137, 0.81568, 0.78431, 1.0) # #D4D0C8
		panel_sb.border_width_left = 2
		panel_sb.border_width_top = 2
		panel_sb.border_width_right = 2
		panel_sb.border_width_bottom = 2
		panel_sb.border_color = Color(0.3, 0.3, 0.3, 1.0)
		panel_sb.corner_radius_top_left = 0
		panel_sb.corner_radius_top_right = 0
		panel_sb.corner_radius_bottom_left = 0
		panel_sb.corner_radius_bottom_right = 0
		panel_sb.content_margin_left = 2
		panel_sb.content_margin_top = 2
		panel_sb.content_margin_right = 2
		panel_sb.content_margin_bottom = 2
		popup.add_theme_stylebox_override("panel", panel_sb)

		# Windows 98 selection highlight: Navy Blue (#000080) bar
		var hover_sb = StyleBoxFlat.new()
		hover_sb.bg_color = Color(0.0, 0.0, 0.502, 1.0) # Windows classic selection blue
		hover_sb.corner_radius_top_left = 0
		hover_sb.corner_radius_top_right = 0
		hover_sb.corner_radius_bottom_left = 0
		hover_sb.corner_radius_bottom_right = 0
		hover_sb.content_margin_left = 4
		hover_sb.content_margin_top = 2
		hover_sb.content_margin_right = 4
		hover_sb.content_margin_bottom = 2
		popup.add_theme_stylebox_override("hover", hover_sb)
		
		# Replace radio/check icons with empty texture for clean retro text dropdown
		var empty_img = Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
		var empty_icon = ImageTexture.create_from_image(empty_img)
		popup.add_theme_icon_override("radio_checked", empty_icon)
		popup.add_theme_icon_override("radio_unchecked", empty_icon)
		popup.add_theme_icon_override("checked", empty_icon)
		popup.add_theme_icon_override("unchecked", empty_icon)
