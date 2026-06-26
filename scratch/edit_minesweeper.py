with open("Scripts/minesweeper.gd", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Add variable declarations
var_target = "var timer_active: bool = false"
var_replace = """var timer_active: bool = false

var sfx_player: AudioStreamPlayer
var click_stream: AudioStreamWAV
var flag_stream: AudioStreamWAV
var explosion_stream: AudioStreamWAV
var win_stream: AudioStreamWAV"""

code = code.replace(var_target, var_replace)

# 2. Update _ready()
ready_target = """func _ready():
	face_button.pressed.connect(reset_game)
	reset_game()"""

ready_replace = """func _ready():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -10.0
	add_child(sfx_player)
	
	click_stream = _generate_click_sound()
	flag_stream = _generate_flag_sound()
	explosion_stream = _generate_explosion_sound()
	win_stream = _generate_win_sound()
	
	face_button.pressed.connect(reset_game)
	reset_game()"""

code = code.replace(ready_target, ready_replace)

# 3. Update _on_cell_gui_input() to play click sound
gui_target = """		if event.button_index == MOUSE_BUTTON_LEFT:
			if not flagged[r][c] and not revealed[r][c]:
				if first_click:
					generate_mines(r, c)
					first_click = false
					timer_active = true
				reveal_cell(r, c)"""

gui_replace = """		if event.button_index == MOUSE_BUTTON_LEFT:
			if not flagged[r][c] and not revealed[r][c]:
				_play_sfx(click_stream)
				if first_click:
					generate_mines(r, c)
					first_click = false
					timer_active = true
				reveal_cell(r, c)"""

code = code.replace(gui_target, gui_replace)

# 4. Update toggle_flag() to play flag sound
flag_target = """func toggle_flag(r: int, c: int):
	flagged[r][c] = not flagged[r][c]"""

flag_replace = """func toggle_flag(r: int, c: int):
	flagged[r][c] = not flagged[r][c]
	_play_sfx(flag_stream)"""

code = code.replace(flag_target, flag_replace)

# 5. Update trigger_game_over() to play win/lose sound
over_target = """	if won:
		face_button.text = "B)" # Sunglasses face
		print("Minesweeper Won!")
		GameStats.casino_balance = round(GameStats.casino_balance + 15.0)
	else:
		face_button.text = "X(" # Dead face"""

over_replace = """	if won:
		_play_sfx(win_stream)
		face_button.text = "B)" # Sunglasses face
		print("Minesweeper Won!")
		GameStats.casino_balance = round(GameStats.casino_balance + 15.0)
	else:
		_play_sfx(explosion_stream)
		face_button.text = "X(" # Dead face"""

code = code.replace(over_target, over_replace)

# 6. Add procedural synthesis helper functions and play function at the end of the file
helper_code = """

func _play_sfx(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()

func _generate_click_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 400 # ~0.036s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-200.0 * t)
		var val = 0.35 if (fmod(t * 800.0, 1.0) < 0.5) else -0.35
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_flag_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 900 # ~0.08s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = (1.0 - t / 0.08)
		var freq = 400.0 + t * 2500.0
		var val = 0.25 if (fmod(t * freq, 1.0) < 0.5) else -0.25
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_explosion_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 6000 # ~0.54s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-8.0 * t)
		var val = (randf() - 0.5) * 0.7 * env
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_win_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 7000 # ~0.63s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 523.25 # C5
		if t > 0.45:
			freq = 1046.50 # C6
		elif t > 0.3:
			freq = 783.99 # G5
		elif t > 0.15:
			freq = 659.25 # E5
		var env = exp(-6.0 * (t - 0.45 if t > 0.45 else (t - 0.3 if t > 0.3 else (t - 0.15 if t > 0.15 else t))))
		var val = 0.35 if (fmod(t * freq, 1.0) < 0.5) else -0.35
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream
"""

# Find the end of check_win_condition()
code += helper_code

with open("Scripts/minesweeper.gd", "w", encoding="utf-8") as f:
    f.write(code)

print("minesweeper.gd edited successfully!")
