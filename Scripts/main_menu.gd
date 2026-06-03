extends Control

@onready var settings_popup = get_node_or_null("SettingsPopup")

func _ready() -> void:
	# Make sure mouse is visible in the main menu
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Connect main menu buttons
	var play_btn = get_node_or_null("MenuButtons/PlayButton")
	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)
		
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

func _on_play_pressed() -> void:
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/Game3D.tscn")

func _on_settings_pressed() -> void:
	if settings_popup:
		settings_popup.visible = true
		# Force synchronization of stats to UI inside SettingsBody
		var body = settings_popup.get_node_or_null("SettingsBody")
		if body and body.has_method("update_ui_from_stats"):
			body.update_ui_from_stats()

func _on_close_settings_pressed() -> void:
	if settings_popup:
		settings_popup.visible = false

func _on_quit_pressed() -> void:
	GameStats.quit_or_menu(get_tree())
