extends Control

@onready var crt_overlay = %CRTOverlay

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if crt_overlay:
		crt_overlay.add_to_group("CRTOverlays")
		crt_overlay.visible = GameStats.crt_effect_enabled
		
	# Wait 1.5 seconds, then load the Main Menu via the loading screen
	await get_tree().create_timer(1.5).timeout
	
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/MainMenu.tscn")
