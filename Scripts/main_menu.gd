extends Control

var normal_tex = preload("res://RetroWindowsGUI/Windows_Button.png")
var hover_tex = preload("res://RetroWindowsGUI/Windows_Button_Focus.png")
var pressed_tex = preload("res://RetroWindowsGUI/Windows_Button_Pressed.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_mouse_entered() -> void:
	%Start.texture = hover_tex


func _on_start_button_mouse_exited() -> void:
	%Start.texture = normal_tex


func _on_start_button_button_down() -> void:
	%Start.texture = pressed_tex


func _on_start_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game3D.tscn")
	%Start.texture = normal_tex


func _on_quit_button_button_down() -> void:
	%StartQuit.texture = pressed_tex


func _on_quit_button_button_up() -> void:
	%StartQuit.texture = normal_tex
	get_tree().quit()


func _on_quit_button_mouse_entered() -> void:
	%StartQuit.texture = hover_tex


func _on_quit_button_mouse_exited() -> void:
	%StartQuit.texture = normal_tex
