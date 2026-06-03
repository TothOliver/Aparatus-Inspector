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

# User System Settings
var mouse_sensitivity: float = 0.15
var crt_effect_enabled: bool = true
var master_volume: float = 80.0

var target_scene_path: String = ""



var button_click_player: AudioStreamPlayer
var button_click_stream: AudioStreamWAV

func _ready():
	button_click_player = AudioStreamPlayer.new()
	button_click_player.volume_db = -10.0
	add_child(button_click_player)
	
	button_click_stream = _generate_button_click_sound()
	
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

func quit_or_menu(tree: SceneTree):
	if tree.current_scene and (tree.current_scene.scene_file_path == "res://Scenes/MainMenu.tscn" or tree.current_scene.name == "MainMenu"):
		tree.quit()
	else:
		final_missed_score = 0
		total_security_breaches = 0
		innocent_robots_killed = 0
		bad_robots_terminated = 0
		is_victory = false
		current_day = 1
		change_scene_with_loading(tree, "res://Scenes/MainMenu.tscn")

func change_scene_with_loading(tree: SceneTree, target_path: String):
	target_scene_path = target_path
	tree.change_scene_to_file("res://Scenes/LoadingScreen.tscn")
