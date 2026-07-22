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

func _on_continue_pressed() -> void:
	if GameStats.load_game():
		GameStats.change_scene_with_loading(get_tree(), "res://Scenes/Game3D.tscn")
	else:
		_on_new_game_pressed()

func _on_new_game_pressed() -> void:
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

func _on_close_settings_pressed() -> void:
	if settings_popup:
		settings_popup.visible = false
		var blocker = get_node_or_null("SettingsBlocker")
		if blocker:
			blocker.visible = false

func _on_quit_pressed() -> void:
	GameStats.quit_or_menu(get_tree())

func _input(event: InputEvent) -> void:
	if settings_popup and settings_popup.visible:
		# Allow closing settings using escape key
		if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			get_viewport().set_input_as_handled()
			_on_close_settings_pressed()
