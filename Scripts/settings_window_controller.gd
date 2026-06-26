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
	visibility_changed.connect(update_ui_from_stats)
	update_ui_from_stats()
	
	if is_pause_menu:
		# Reposition Exit Game button dynamically to make space for Resume button
		if quit_button:
			quit_button.pressed.connect(_on_quit_pressed)
			quit_button.position = Vector2(246, 360)
			quit_button.size = Vector2(120, 30)

		# Dynamically instantiate the Resume button
		var resume_button = Button.new()
		resume_button.name = "ResumeButton"
		resume_button.text = "Resume"
		resume_button.add_theme_font_override("font", preload("res://RetroWindowsGUI/windows-bold[1].ttf"))
		resume_button.add_theme_font_size_override("font_size", 12)
		resume_button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		resume_button.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
		resume_button.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 1))
		resume_button.add_theme_color_override("font_focus_color", Color(0, 0, 0, 1))
		resume_button.add_theme_stylebox_override("normal", preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres"))
		resume_button.add_theme_stylebox_override("hover", preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres"))
		resume_button.add_theme_stylebox_override("pressed", preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres"))
		resume_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		resume_button.position = Vector2(60, 360)
		resume_button.size = Vector2(120, 30)
		resume_button.pressed.connect(_on_resume_pressed)
		add_child(resume_button)

		# Divert TitleBar CloseButton (x) to unpause the tree
		var close_button = get_node_or_null("../TitleBar/CloseButton")
		if close_button:
			for conn in close_button.pressed.get_connections():
				close_button.pressed.disconnect(conn.callable)
			close_button.pressed.connect(_on_resume_pressed)
	else:
		# 2D OS Settings Menu: Just connect the quit button normally (don't move it)
		if quit_button:
			quit_button.pressed.connect(_on_quit_pressed)

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
	if is_inside_tree():
		for crt in get_tree().get_nodes_in_group("CRTOverlays"):
			crt.visible = toggled_on



func _on_volume_changed(value: float):
	GameStats.master_volume = value
	if volume_value_label:
		volume_value_label.text = str(round(value)) + "%"
	
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
