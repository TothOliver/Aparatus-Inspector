with open("Scripts/gameStats.gd", "r", encoding="utf-8") as f:
    code = f.read()

helper_code = """

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
"""

code += helper_code

with open("Scripts/gameStats.gd", "w", encoding="utf-8") as f:
    f.write(code)

print("gameStats.gd updated successfully!")
