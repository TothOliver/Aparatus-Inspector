extends Control

@onready var settings_popup = get_node_or_null("SettingsPopup")

func _ready() -> void:
	# Make sure mouse is visible in the main menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Preload main 3D game scene in background thread while player is in Main Menu
	ResourceLoader.load_threaded_request("res://Scenes/Game3D.tscn")
	
	# Create modal blocker overlay dynamically
	var blocker = ColorRect.new()
	blocker.name = "SettingsBlocker"
	blocker.color = Color(0, 0, 0, 0.4) # Slightly dim the background to feel premium
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.visible = false
	add_child(blocker)
	
	if settings_popup:
		# Make sure blocker is behind settings_popup but in front of main menu buttons
		var popup_index = settings_popup.get_index()
		move_child(blocker, popup_index)
	
	# Dynamically center main menu controls for expand stretch aspect
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()
	
	# Connect main menu buttons
	var continue_btn = get_node_or_null("MenuButtons/ContinueButton")
	var play_btn = get_node_or_null("MenuButtons/PlayButton")
	var has_save = GameStats.has_save_file()
	
	if continue_btn:
		continue_btn.visible = has_save
		if has_save:
			continue_btn.pressed.connect(_on_continue_pressed)
			
	if play_btn:
		play_btn.text = "Start New Game"
		play_btn.pressed.connect(_on_new_game_pressed)
		
	var settings_btn = get_node_or_null("MenuButtons/SettingsButton")
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
		
	var quit_btn = get_node_or_null("MenuButtons/QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

	var close_btn = get_node_or_null("SettingsPopup/TitleBar/CloseButton")
	if close_btn:
		close_btn.pressed.connect(_on_close_settings_pressed)
		
	# Register main menu CRT overlay if exists
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		crt.add_to_group("CRTOverlays")
		crt.visible = GameStats.crt_effect_enabled

	if has_node("/root/BGMusic"):
		var bg_music = get_node("/root/BGMusic")
		if bg_music is AudioStreamPlayer and not bg_music.playing:
			bg_music.play()

func _on_viewport_size_changed() -> void:
	var viewport_size = get_viewport_rect().size
	var briefing = get_node_or_null("Background")
	if briefing:
		briefing.position.x = (viewport_size.x - briefing.size.x) / 2.0
	var buttons = get_node_or_null("MenuButtons")
	if buttons:
		buttons.position.x = (viewport_size.x - buttons.size.x) / 2.0
	if settings_popup:
		settings_popup.position.x = (viewport_size.x - settings_popup.size.x) / 2.0
	var diff_popup = get_node_or_null("DifficultyPopup")
	if diff_popup:
		_center_difficulty_popup(diff_popup)

func _on_continue_pressed() -> void:
	if GameStats.load_game():
		GameStats.change_scene_with_loading(get_tree(), "res://Scenes/Game3D.tscn")
	else:
		_on_new_game_pressed()

func _on_new_game_pressed() -> void:
	_show_difficulty_popup()

func _show_difficulty_popup() -> void:
	var popup = get_node_or_null("DifficultyPopup")
	if not popup:
		popup = _create_difficulty_popup()
		add_child(popup)
	var blocker = get_node_or_null("SettingsBlocker")
	if blocker:
		blocker.visible = true
		var blocker_idx = blocker.get_index()
		move_child(popup, blocker_idx + 1)
	popup.visible = true
	_center_difficulty_popup(popup)
	
	# Ensure CRT shader overlay covers difficulty popup
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		move_child(crt, get_child_count() - 1)

func _center_difficulty_popup(popup: Control) -> void:
	if popup:
		var viewport_size = get_viewport_rect().size
		popup.position.x = (viewport_size.x - popup.size.x) / 2.0
		popup.position.y = (viewport_size.y - popup.size.y) / 2.0

func _create_difficulty_popup() -> Control:
	var window = NinePatchRect.new()
	window.name = "DifficultyPopup"
	window.custom_minimum_size = Vector2(450, 360)
	window.size = Vector2(450, 360)
	window.texture = preload("res://RetroWindowsGUI/Window_Base.png")
	window.patch_margin_left = 12
	window.patch_margin_top = 12
	window.patch_margin_right = 12
	window.patch_margin_bottom = 12
	
	# Title Bar
	var title_bar = NinePatchRect.new()
	title_bar.name = "TitleBar"
	title_bar.position = Vector2(6, 6)
	title_bar.custom_minimum_size = Vector2(438, 30)
	title_bar.size = Vector2(438, 30)
	title_bar.texture = preload("res://RetroWindowsGUI/Window_Header.png")
	title_bar.region_rect = Rect2(0, 0, 48, 25)
	title_bar.patch_margin_left = 5
	title_bar.patch_margin_top = 3
	title_bar.patch_margin_right = 5
	title_bar.patch_margin_bottom = 3
	window.add_child(title_bar)
	
	var font_bold = preload("res://RetroWindowsGUI/windows-bold[1].ttf")
	var font_regular = preload("res://RetroWindowsGUI/M 8pt.ttf")
	var btn_normal = preload("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
	var btn_hover = preload("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
	var btn_pressed = preload("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
	var exit_icon = preload("res://RetroWindowsGUI/ExitButton.png")
	
	var title_label = Label.new()
	title_label.text = "Select Game Mode / Difficulty"
	title_label.position = Vector2(8, 6)
	title_label.add_theme_font_override("font", font_bold)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title_bar.add_child(title_label)
	
	var close_btn = Button.new()
	close_btn.position = Vector2(414, 5)
	close_btn.custom_minimum_size = Vector2(20, 20)
	close_btn.size = Vector2(20, 20)
	close_btn.icon = exit_icon
	close_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	close_btn.add_theme_stylebox_override("normal", btn_normal)
	close_btn.add_theme_stylebox_override("hover", btn_hover)
	close_btn.add_theme_stylebox_override("pressed", btn_pressed)
	close_btn.pressed.connect(func(): _close_difficulty_popup())
	title_bar.add_child(close_btn)
	
	# VBox Container for options
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(16, 42)
	vbox.custom_minimum_size = Vector2(418, 305)
	vbox.size = Vector2(418, 305)
	vbox.add_theme_constant_override("separation", 6)
	window.add_child(vbox)
	
	# Header Label
	var header = Label.new()
	header.text = "CHOOSE YOUR INSPECTION SHIFT MODE:"
	header.add_theme_font_override("font", font_bold)
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", Color(0.0, 0.0, 0.5, 1))
	vbox.add_child(header)
	
	# Helper for retro buttons
	var create_mode_btn = func(text_str: String, mode: GameStats.DifficultyMode) -> Button:
		var btn = Button.new()
		btn.text = text_str
		btn.custom_minimum_size = Vector2(418, 28)
		btn.add_theme_font_override("font", font_bold)
		btn.add_theme_font_size_override("font_size", 13)
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		btn.add_theme_color_override("font_hover_color", Color(0, 0, 0.5, 1))
		btn.pressed.connect(func(): _select_difficulty(mode))
		return btn

	# 1. NORMAL MODE
	var norm_btn = create_mode_btn.call("Normal", GameStats.DifficultyMode.NORMAL)
	vbox.add_child(norm_btn)
	
	var norm_lbl = Label.new()
	norm_lbl.text = " • Standard shift experience. Max 2 breaches allowed."
	norm_lbl.add_theme_font_override("font", font_regular)
	norm_lbl.add_theme_font_size_override("font_size", 12)
	norm_lbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1, 1))
	norm_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(norm_lbl)
	
	# 2. HARD MODE
	var hard_btn = create_mode_btn.call("Hard", GameStats.DifficultyMode.HARD)
	vbox.add_child(hard_btn)
	
	var hard_lbl = Label.new()
	hard_lbl.text = " • Permadeath. Max 2 breaches allowed."
	hard_lbl.add_theme_font_override("font", font_regular)
	hard_lbl.add_theme_font_size_override("font_size", 12)
	hard_lbl.add_theme_color_override("font_color", Color(0.4, 0.2, 0.0, 1))
	hard_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hard_lbl)
	
	# 3. NIGHTMARE MODE
	var night_btn = create_mode_btn.call("Nightmare", GameStats.DifficultyMode.NIGHTMARE)
	vbox.add_child(night_btn)
	
	var night_lbl = Label.new()
	night_lbl.text = " • Permadeath. Max 1 breach allowed."
	night_lbl.add_theme_font_override("font", font_regular)
	night_lbl.add_theme_font_size_override("font_size", 12)
	night_lbl.add_theme_color_override("font_color", Color(0.6, 0.0, 0.0, 1))
	night_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(night_lbl)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	# Bottom row for Back button (Centered)
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	var back_btn = Button.new()
	back_btn.text = "Back"
	back_btn.custom_minimum_size = Vector2(120, 28)
	back_btn.add_theme_font_override("font", font_bold)
	back_btn.add_theme_font_size_override("font_size", 13)
	back_btn.add_theme_stylebox_override("normal", btn_normal)
	back_btn.add_theme_stylebox_override("hover", btn_hover)
	back_btn.add_theme_stylebox_override("pressed", btn_pressed)
	back_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	back_btn.pressed.connect(func(): _close_difficulty_popup())
	hbox.add_child(back_btn)

	return window

func _close_difficulty_popup() -> void:
	var popup = get_node_or_null("DifficultyPopup")
	if popup:
		popup.visible = false
	var blocker = get_node_or_null("SettingsBlocker")
	if blocker:
		blocker.visible = false

func _select_difficulty(mode: GameStats.DifficultyMode) -> void:
	_close_difficulty_popup()
	GameStats.difficulty_mode = mode
	GameStats.reset_game_state()
	GameStats.delete_save_game()
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/Game3D.tscn")

func _on_settings_pressed() -> void:
	if settings_popup:
		var blocker = get_node_or_null("SettingsBlocker")
		if blocker:
			blocker.visible = true
		settings_popup.visible = true
		# Force synchronization of stats to UI inside SettingsBody
		var body = settings_popup.get_node_or_null("SettingsBody")
		if body and body.has_method("update_ui_from_stats"):
			body.update_ui_from_stats()
	# Ensure CRT shader overlay covers settings popup
	var crt = get_node_or_null("CRTOverlay")
	if crt:
		move_child(crt, get_child_count() - 1)

func _on_close_settings_pressed() -> void:
	if settings_popup:
		settings_popup.visible = false
		var blocker = get_node_or_null("SettingsBlocker")
		if blocker:
			blocker.visible = false

func _on_quit_pressed() -> void:
	GameStats.quit_or_menu(get_tree())

func _input(event: InputEvent) -> void:
	var diff_popup = get_node_or_null("DifficultyPopup")
	if diff_popup and diff_popup.visible:
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			get_viewport().set_input_as_handled()
			_close_difficulty_popup()
			return

	if settings_popup and settings_popup.visible:
		# Allow closing settings using escape key
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			get_viewport().set_input_as_handled()
			_on_close_settings_pressed()
