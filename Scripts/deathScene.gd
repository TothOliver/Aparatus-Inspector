extends Control

@onready var title_label = %Title
@onready var stats_label = %StatsLabel
@onready var gameOverSFX = $gameOverSFX

func _ready():
	if has_node("CRTOverlay"):
		$CRTOverlay.visible = GameStats.crt_effect_enabled
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if GameStats.is_victory:
		if GameStats.IS_DEMO:
			title_label.text = "DEMO COMPLETED"
		else:
			title_label.text = "SHIFT COMPLETED"
	else:
		title_label.text = "GAME OVER"
	display_message()
	if has_node("/root/BGMusic"):
		var bg_music = get_node("/root/BGMusic")
		if bg_music is AudioStreamPlayer:
			bg_music.stop()

	if GameStats.is_victory:
		GameStats.play_victory_sound()
		_setup_demo_wishlist_button()
	else:
		gameOverSFX.play()
	
	var menu_btn = get_node_or_null("Window/MainMenu")
	if menu_btn:
		menu_btn.pressed.connect(_on_main_menu_pressed)

func display_message():
	if GameStats.is_victory:
		if GameStats.IS_DEMO:
			stats_label.text = "DEMO COMPLETE\n\nThank you for playing the Apparatus Inspector demo!\nWishlist on Steam to support further development."
		else:
			stats_label.text = "SHIFT COMPLETE\n\nAll inspection directives concluded successfully.\nFacility integrity maintained."
	else:
		stats_label.text = "INSPECTOR DECOMMISSIONED\n\nSecurity breach threshold reached.\nFacility protocols compromised."

func _on_restart_pressed() -> void:
	if GameStats.difficulty_mode == GameStats.DifficultyMode.NORMAL:
		GameStats.reset_current_day_state()
	else:
		GameStats.reset_game_state()
		GameStats.delete_save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://Scenes/Game3D.tscn")

func _on_main_menu_pressed() -> void:
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/MainMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _setup_demo_wishlist_button() -> void:
	if not GameStats.IS_DEMO:
		return
	var window = get_node_or_null("Window")
	if not window:
		return
	var restart_btn = window.get_node_or_null("Restart") as Button
	if restart_btn:
		restart_btn.text = "★ Wishlist ★"
		if restart_btn.pressed.is_connected(_on_restart_pressed):
			restart_btn.pressed.disconnect(_on_restart_pressed)
		restart_btn.pressed.connect(func():
			GameStats.open_steam_store()
			restart_btn.text = "Opened ✓"
		)
