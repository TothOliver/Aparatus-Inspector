extends Control

@onready var game_timer = $GameTimer
@onready var score_label = $HeaderPanel/ScoreLabel
@onready var status_label = $HeaderPanel/StatusLabel
@onready var start_button = $HeaderPanel/StartButton
@onready var game_area = $GameArea

var grid_width: int = 20
var grid_height: int = 18
var cell_size: float = 18.0

var snake: Array = [] # Array of Vector2i (grid coords)
var direction: Vector2i = Vector2i.RIGHT
var next_direction: Vector2i = Vector2i.RIGHT
var food: Vector2i = Vector2i.ZERO

var score: int = 0
var game_running: bool = false
var game_over: bool = false

var sfx_player: AudioStreamPlayer
var tick_stream: AudioStreamWAV
var eat_stream: AudioStreamWAV
var die_stream: AudioStreamWAV

func _ready():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -12.0
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	tick_stream = _generate_tick_sound()
	eat_stream = _generate_eat_sound()
	die_stream = _generate_die_sound()

	start_button.pressed.connect(start_game)
	game_timer.timeout.connect(game_tick)
	
	# Custom draw connect on the GameArea child Control
	game_area.draw.connect(_on_game_area_draw)
	
	# Make focusable
	focus_mode = FocusMode.FOCUS_ALL
	
	# Grab focus when clicking the game area
	game_area.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			grab_focus()
	)
	
	reset_board()

func reset_board():
	score = 0
	score_label.text = "Score: 0"
	status_label.text = "Ready to Play"
	game_over = false
	game_running = false
	game_timer.stop()
	
	# Set start snake position
	snake = [
		Vector2i(5, 9),
		Vector2i(4, 9),
		Vector2i(3, 9)
	]
	direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT
	
	spawn_food()
	game_area.queue_redraw()

func start_game():
	reset_board()
	game_running = true
	status_label.text = "Playing"
	grab_focus() # Grab keyboard focus
	game_timer.start(0.14) # Speed tick rate

func spawn_food():
	var attempts = 0
	while attempts < 1000:
		attempts += 1
		var r_pos = Vector2i(randi() % grid_width, randi() % grid_height)
		if not r_pos in snake:
			food = r_pos
			break

func _input(event):
	if not game_running or game_over:
		return
		
	if not has_focus():
		return
		
	if event is InputEventKey and event.pressed:
		var dir_check = Vector2i.ZERO
		match event.keycode:
			KEY_UP, KEY_W: dir_check = Vector2i.UP
			KEY_DOWN, KEY_S: dir_check = Vector2i.DOWN
			KEY_LEFT, KEY_A: dir_check = Vector2i.LEFT
			KEY_RIGHT, KEY_D: dir_check = Vector2i.RIGHT
			
		if dir_check != Vector2i.ZERO:
			# Prevent turning directly backward
			if dir_check + direction != Vector2i.ZERO:
				next_direction = dir_check
				accept_event() # Consume event

func game_tick():
	if not game_running or game_over:
		return
		
	direction = next_direction
	var head = snake[0] + direction
	
	# Check boundary collision
	if head.x < 0 or head.x >= grid_width or head.y < 0 or head.y >= grid_height:
		end_game()
		return
		
	# Check self collision
	if head in snake:
		end_game()
		return
		
	# Move snake head
	snake.insert(0, head)
	
	# Check food collision
	if head == food:
		_play_sfx(eat_stream)
		score += 10
		score_label.text = "Score: " + str(score)
		GameStats.casino_balance = round(GameStats.casino_balance + 1.0)
		spawn_food()
	else:
		_play_sfx(tick_stream)
		# Remove tail segment if food not eaten
		snake.pop_back()
		
	game_area.queue_redraw()

func end_game():
	_play_sfx(die_stream)
	game_over = true
	game_running = false
	game_timer.stop()
	status_label.text = "GAME OVER"
	game_area.queue_redraw()

func _on_game_area_draw():
	# Draw background grid fill
	game_area.draw_rect(Rect2(Vector2.ZERO, game_area.size), Color(0.05, 0.05, 0.05, 1))
	
	# Draw border lines
	game_area.draw_rect(Rect2(Vector2.ZERO, game_area.size), Color(0.3, 0.3, 0.3, 1), false, 2.0)
	
	# Draw food (red rect)
	var food_rect = Rect2(Vector2(food.x, food.y) * cell_size + Vector2(1,1), Vector2(cell_size - 2, cell_size - 2))
	game_area.draw_rect(food_rect, Color(0.9, 0.15, 0.15, 1))
	
	# Draw snake body
	for i in range(snake.size()):
		var segment = snake[i]
		var segment_rect = Rect2(Vector2(segment.x, segment.y) * cell_size + Vector2(1,1), Vector2(cell_size - 2, cell_size - 2))
		
		# Head color is slightly lighter/different green than body
		var color = Color(0.15, 0.85, 0.15, 1) if i == 0 else Color(0.1, 0.6, 0.1, 1)
		game_area.draw_rect(segment_rect, color)


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
