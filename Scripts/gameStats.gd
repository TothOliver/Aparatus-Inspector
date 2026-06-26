extends Node

var final_missed_score: int = 0
var total_security_breaches: int = 0
var innocent_robots_killed: int = 0
var good_robots_through: int = 0
var bad_robots_terminated: int = 0
var let_through_bad_sprites: Array = []

# Gameplay depth additions
var current_day: int = 1
var power_level: float = 100.0
var door_locked: bool = false
var hack_active: bool = false
var hack_progress: float = 0.0
var is_victory: bool = false
var casino_balance: float = 100.0
var wifi_on: bool = true
var player_health: float = 100.0
var player_sanity: float = 100.0

# User System Settings
var mouse_sensitivity: float = 0.15
var crt_effect_enabled: bool = true
var master_volume: float = 80.0
var fullscreen_enabled: bool = true

signal fullscreen_toggled(is_fullscreen: bool)

var target_scene_path: String = ""



var button_click_player: AudioStreamPlayer
var button_click_stream: AudioStreamWAV

func _ready():
	button_click_player = AudioStreamPlayer.new()
	button_click_player.volume_db = -10.0
	add_child(button_click_player)
	
	button_click_stream = _generate_button_click_sound()
	
	# Initialize fullscreen mode based on setting
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Listen to new nodes added to the tree dynamically
	get_tree().node_added.connect(_on_node_added)
	
	# Recursively connect to all buttons currently in the tree
	_connect_buttons_recursive(get_tree().root)

func _on_node_added(node: Node):
	if node is Button:
		_connect_button(node)

func _connect_buttons_recursive(node: Node):
	if node is Button:
		_connect_button(node)
	for child in node.get_children():
		_connect_buttons_recursive(child)

func _connect_button(btn: Button):
	if not btn.pressed.is_connected(_play_button_click):
		btn.pressed.connect(_play_button_click)

func _play_button_click():
	if button_click_player and button_click_stream:
		button_click_player.stream = button_click_stream
		button_click_player.play()

func _generate_button_click_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 300 # ~0.027s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-250.0 * t)
		# 600Hz clean blip
		var val = 0.25 if (fmod(t * 600.0, 1.0) < 0.5) else -0.25
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func reset_game_state():
	final_missed_score = 0
	total_security_breaches = 0
	innocent_robots_killed = 0
	good_robots_through = 0
	bad_robots_terminated = 0
	let_through_bad_sprites.clear()
	
	current_day = 1
	power_level = 100.0
	door_locked = false
	hack_active = false
	hack_progress = 0.0
	is_victory = false
	casino_balance = 100.0
	wifi_on = true
	player_health = 100.0
	player_sanity = 100.0

func quit_or_menu(tree: SceneTree):
	if tree.current_scene and (tree.current_scene.scene_file_path == "res://Scenes/MainMenu.tscn" or tree.current_scene.name == "MainMenu"):
		tree.quit()
	else:
		reset_game_state()
		tree.paused = false
		tree.change_scene_to_file("res://Scenes/MainMenu.tscn")

func change_scene_with_loading(tree: SceneTree, target_path: String):
	target_scene_path = target_path
	tree.paused = false
	tree.change_scene_to_file("res://Scenes/LoadingScreen.tscn")

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var is_f11 = event.keycode == KEY_F11
		var is_enter = event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER
		var is_alt_enter = is_enter and event.alt_pressed
		if is_f11 or is_alt_enter:
			get_viewport().set_input_as_handled()
			var mode = DisplayServer.window_get_mode()
			if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				fullscreen_enabled = false
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				fullscreen_enabled = true
			fullscreen_toggled.emit(fullscreen_enabled)
