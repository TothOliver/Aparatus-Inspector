extends Control

@onready var title_label = %Title
@onready var stats_label = %StatsLabel
@onready var gameOverSFX = $gameOverSFX

func _ready():
	if has_node("CRTOverlay"):
		$CRTOverlay.visible = GameStats.crt_effect_enabled
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if GameStats.is_victory:
		title_label.text = "SHIFT COMPLETED / VICTORY!"
	else:
		title_label.text = "GAME OVER"
	display_stats()
	if has_node("/root/BGMusic"):
		var bg_music = get_node("/root/BGMusic")
		if bg_music is AudioStreamPlayer:
			bg_music.stop()

	if GameStats.is_victory:
		GameStats.play_victory_sound()
	else:
		gameOverSFX.play()
	
	var menu_btn = get_node_or_null("Window/MainMenu")
	if menu_btn:
		menu_btn.pressed.connect(_on_main_menu_pressed)

func display_stats():
	var calculated_score = GameStats.bad_robots_terminated + GameStats.good_robots_through - GameStats.innocent_robots_killed
	
	var terminated = GameStats.bad_robots_terminated 
	var breaches = GameStats.total_security_breaches
	var innocents = GameStats.innocent_robots_killed
	
	var grade = calculate_grade(calculated_score)
	
	stats_label.text = "Bad robots EXTERMINATED: " + str(terminated) 
	stats_label.text += "\nTOTAL BREACHES: " + str(breaches)
	stats_label.text += "\nINNOCENTS TERMINATED: " + str(innocents)
	stats_label.text += "\nPERFORMANCE GRADE: " + grade

func calculate_grade(score: int) -> String:
	if score >= 20:
		return "A+"
	elif score >= 15:
		return "A"
	elif score >= 10:
		return "B"
	elif score >= 5:
		return "C"
	elif score >= 1:
		return "D"
	else:
		return "F"

func _on_restart_pressed() -> void:
	if GameStats.has_save_file():
		GameStats.load_game()
	else:
		GameStats.reset_game_state()
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/Game3D.tscn")

func _on_main_menu_pressed() -> void:
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/MainMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
