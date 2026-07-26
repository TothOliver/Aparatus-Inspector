extends Control

@onready var crt_overlay = %CRTOverlay

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_warmup_shaders()
	
	if crt_overlay:
		crt_overlay.add_to_group("CRTOverlays")
		crt_overlay.visible = GameStats.crt_effect_enabled
		
	# Wait 1.5 seconds, then load the Main Menu via the loading screen
	await get_tree().create_timer(1.5).timeout
	
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/MainMenu.tscn")

func _warmup_shaders() -> void:
	# Instantiate dummy off-screen nodes for GPU shader pipeline pre-compilation
	var crt_shader = preload("res://crt_filter.gdshader")
	var screensaver_shader = preload("res://Shaders/retro_screensaver.gdshader")
	
	var warm_container = Control.new()
	warm_container.modulate.a = 0.001
	add_child(warm_container)
	
	var crt_rect = ColorRect.new()
	var mat_crt = ShaderMaterial.new()
	mat_crt.shader = crt_shader
	crt_rect.material = mat_crt
	warm_container.add_child(crt_rect)
	
	var ss_rect = ColorRect.new()
	var mat_ss = ShaderMaterial.new()
	mat_ss.shader = screensaver_shader
	ss_rect.material = mat_ss
	warm_container.add_child(ss_rect)
