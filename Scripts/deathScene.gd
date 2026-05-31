extends Control

# This connects the Label node to the script
@onready var stats_label = %StatsLabel
@onready var gameOverSFX =$gameOverSFX

func _ready():
	# This runs the moment the Death/Victory Scene appears on screen
	if GameStats.is_victory:
		$Title.text = "SHIFT COMPLETED / VICTORY!"
	display_stats()
	gameOverSFX.play()

# Scripts/deathScene.gd

func display_stats():
	# This 'score' variable is what was likely breaking your display logic
	var calculated_score = GameStats.bad_robots_terminated + GameStats.good_robots_through - GameStats.innocent_robots_killed
	
	# These are the raw numbers you actually want to show
	var terminated = GameStats.bad_robots_terminated 
	var breaches = GameStats.total_security_breaches
	var innocents = GameStats.innocent_robots_killed
	
	# Get the grade based on your actual performance score
	var grade = calculate_grade(calculated_score)
	
	# FIX: Ensure you are using 'terminated' here, NOT 'score'
	stats_label.text = "Bad robots EXTERMINATED: " + str(terminated) 
	stats_label.text += "\nTOTAL BREACHES: " + str(breaches)
	stats_label.text += "\nINNOCENTS TERMINATED: " + str(innocents)
	stats_label.text += "\nPERFORMANCE GRADE: " + grade
	

func calculate_grade(score: int) -> String:
	# High score is better (More bad robots exterminated)
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

var normal_tex = preload("res://RetroWindowsGUI/Windows_Button.png")
var hover_tex = preload("res://RetroWindowsGUI/Windows_Button_Focus.png")
var pressed_tex = preload("res://RetroWindowsGUI/Windows_Button_Pressed.png")
# In Scripts/deathScene.gd
func _on_restart_button_down() -> void:
	%RestartRect.texture = pressed_tex


func _on_restart_button_up() -> void:
	GameStats.final_missed_score = 0
	GameStats.total_security_breaches = 0
	GameStats.innocent_robots_killed = 0 # Reset here
	GameStats.bad_robots_terminated = 0 # Reset this!
	GameStats.is_victory = false
	GameStats.current_day = 1
	get_tree().change_scene_to_file("res://Scenes/Game3D.tscn")







func _on_restart_mouse_entered() -> void:
	%RestartRect.texture = hover_tex


func _on_restart_mouse_exited() -> void:
	%RestartRect.texture = normal_tex




func _on_quit_mouse_entered() -> void:
	%QuitRect.texture = hover_tex



func _on_quit_mouse_exited() -> void:
	%QuitRect.texture = normal_tex


func _on_quit_button_down() -> void:
	%QuitRect.texture = pressed_tex


func _on_quit_button_up() -> void:
	get_tree().quit()
