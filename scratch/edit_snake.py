with open("Scripts/snake.gd", "r", encoding="utf-8") as f:
    code = f.read()

# 1. Add variable declarations
var_target = "var game_over: bool = false"
var_replace = """var game_over: bool = false

var sfx_player: AudioStreamPlayer
var tick_stream: AudioStreamWAV
var eat_stream: AudioStreamWAV
var die_stream: AudioStreamWAV"""

code = code.replace(var_target, var_replace)

# 2. Update _ready()
ready_target = """func _ready():
	start_button.pressed.connect(start_game)"""

ready_replace = """func _ready():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -12.0
	add_child(sfx_player)
	
	tick_stream = _generate_tick_sound()
	eat_stream = _generate_eat_sound()
	die_stream = _generate_die_sound()

	start_button.pressed.connect(start_game)"""

code = code.replace(ready_target, ready_replace)

# 3. Update game_tick() for eat/move sounds
tick_target = """	# Check food collision
	if head == food:
		score += 10
		score_label.text = "Score: " + str(score)
		GameStats.casino_balance = round(GameStats.casino_balance + 1.0)
		spawn_food()
	else:
		# Remove tail segment if food not eaten
		snake.pop_back()"""

tick_replace = """	# Check food collision
	if head == food:
		_play_sfx(eat_stream)
		score += 10
		score_label.text = "Score: " + str(score)
		GameStats.casino_balance = round(GameStats.casino_balance + 1.0)
		spawn_food()
	else:
		_play_sfx(tick_stream)
		# Remove tail segment if food not eaten
		snake.pop_back()"""

code = code.replace(tick_target, tick_replace)

# 4. Update end_game() to play die sound
end_target = """func end_game():
	game_over = true
	game_running = false
	game_timer.stop()
	status_label.text = "GAME OVER"
	game_area.queue_redraw()"""

end_replace = """func end_game():
	_play_sfx(die_stream)
	game_over = true
	game_running = false
	game_timer.stop()
	status_label.text = "GAME OVER"
	game_area.queue_redraw()"""

code = code.replace(end_target, end_replace)

# 5. Add procedural sound generators and play function at the end
helper_code = """

func _play_sfx(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()

func _generate_tick_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 150 # ~0.013s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-350.0 * t)
		var val = (randf() - 0.5) * 0.08 * env
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_eat_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 1300 # ~0.11s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-35.0 * t)
		var freq = 600.0 + t * 3000.0
		var val = 0.35 if (fmod(t * freq, 1.0) < 0.5) else -0.35
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_die_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 5000 # ~0.45s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-7.0 * t)
		var freq = 350.0 - t * 600.0
		freq = max(60.0, freq)
		var val = 0.45 if (fmod(t * freq, 1.0) < 0.5) else -0.45
		if randf() < 0.15:
			val += (randf() - 0.5) * 0.4
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream
"""

code += helper_code

with open("Scripts/snake.gd", "w", encoding="utf-8") as f:
    f.write(code)

print("snake.gd edited successfully!")
