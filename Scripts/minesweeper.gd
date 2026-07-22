extends Control

@onready var grid_container = $GridContainer
@onready var mine_label = $HeaderPanel/MineLabel
@onready var face_button = $HeaderPanel/FaceButton
@onready var timer_label = $HeaderPanel/TimerLabel

var grid_size: int = 9
var total_mines: int = 10
var cells: Array = [] # 2D array of Button nodes
var grid_data: Array = [] # 2D array of ints: -1 = mine, 0-8 = adjacent mine count
var revealed: Array = [] # 2D array of bools
var flagged: Array = [] # 2D array of bools

var first_click: bool = true
var game_over: bool = false
var time_elapsed: float = 0.0
var timer_active: bool = false

var sfx_player: AudioStreamPlayer
var click_stream: AudioStreamWAV
var flag_stream: AudioStreamWAV
var explosion_stream: AudioStreamWAV
var win_stream: AudioStreamWAV

# Retro colors for mine counts
var number_colors = {
	1: Color(0, 0, 1),       # Blue
	2: Color(0, 0.5, 0),     # Green
	3: Color(1, 0, 0),       # Red
	4: Color(0, 0, 0.5),     # Dark Blue
	5: Color(0.5, 0, 0),     # Maroon
	6: Color(0, 0.5, 0.5),   # Teal
	7: Color(0, 0, 0),       # Black
	8: Color(0.5, 0.5, 0.5)  # Grey
}

func _ready():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -10.0
	add_child(sfx_player)
	
	click_stream = _generate_click_sound()
	flag_stream = _generate_flag_sound()
	explosion_stream = _generate_explosion_sound()
	win_stream = _generate_win_sound()
	
	face_button.pressed.connect(reset_game)
	reset_game()

func _process(delta):
	if timer_active:
		time_elapsed += delta
		timer_label.text = "%03d" % int(time_elapsed)

func reset_game():
	# Clear old buttons
	for child in grid_container.get_children():
		child.queue_free()
		
	cells.clear()
	grid_data.clear()
	revealed.clear()
	flagged.clear()
	
	first_click = true
	game_over = false
	time_elapsed = 0.0
	timer_active = false
	timer_label.text = "000"
	mine_label.text = "%02d" % total_mines
	face_button.text = ":)" # Smiley face
	
	# Initialize arrays
	for r in range(grid_size):
		var row_cells = []
		var row_data = []
		var row_rev = []
		var row_flag = []
		for c in range(grid_size):
			var button = Button.new()
			button.custom_minimum_size = Vector2(32, 32)
			button.add_theme_font_override("font", load("res://RetroWindowsGUI/windows-bold[1].ttf"))
			button.add_theme_font_size_override("font_size", 14)
			var normal_style = load("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
			var hover_style = load("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
			var pressed_style = load("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
			button.add_theme_stylebox_override("normal", normal_style)
			button.add_theme_stylebox_override("hover", hover_style)
			button.add_theme_stylebox_override("pressed", pressed_style)
			button.add_theme_stylebox_override("focus", hover_style)
			
			# Setup input filters for left/right click
			button.gui_input.connect(func(event): _on_cell_gui_input(event, r, c))
			
			grid_container.add_child(button)
			row_cells.append(button)
			row_data.append(0)
			row_rev.append(false)
			row_flag.append(false)
			
		cells.append(row_cells)
		grid_data.append(row_data)
		revealed.append(row_rev)
		flagged.append(row_flag)

func _on_cell_gui_input(event: InputEvent, r: int, c: int):
	if game_over:
		return
		
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not flagged[r][c] and not revealed[r][c]:
				_play_sfx(click_stream)
				if first_click:
					generate_mines(r, c)
					first_click = false
					timer_active = true
				reveal_cell(r, c)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if not revealed[r][c]:
				toggle_flag(r, c)

func generate_mines(start_r: int, start_c: int):
	var mine_positions = []
	var attempts = 0
	
	# Place mines randomly
	while mine_positions.size() < total_mines and attempts < 1000:
		attempts += 1
		var r = randi() % grid_size
		var c = randi() % grid_size
		
		# Prevent placing on starting cell or its direct neighbors
		if abs(r - start_r) <= 1 and abs(c - start_c) <= 1:
			continue
			
		var pos = Vector2i(r, c)
		if not pos in mine_positions:
			mine_positions.append(pos)
			grid_data[r][c] = -1 # Mine
			
	# Calculate neighbor values
	for r in range(grid_size):
		for c in range(grid_size):
			if grid_data[r][c] == -1:
				continue
				
			# Count adjacent mines
			var count = 0
			for dr in [-1, 0, 1]:
				for dc in [-1, 0, 1]:
					var nr = r + dr
					var nc = c + dc
					if nr >= 0 and nr < grid_size and nc >= 0 and nc < grid_size:
						if grid_data[nr][nc] == -1:
							count += 1
			grid_data[r][c] = count

func reveal_cell(r: int, c: int):
	if revealed[r][c] or flagged[r][c]:
		return
		
	revealed[r][c] = true
	var btn = cells[r][c]
	btn.disabled = true
	
	# Style revealed cell (flat look)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.8, 0.8, 0.8, 1)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_color = Color(0.6, 0.6, 0.6, 1)
	btn.add_theme_stylebox_override("disabled", style_box)

	if grid_data[r][c] == -1:
		# Hit a mine!
		btn.text = "*"
		btn.add_theme_color_override("font_disabled_color", Color(1, 0, 0, 1)) # Red mine
		trigger_game_over(false)
	elif grid_data[r][c] > 0:
		var num = grid_data[r][c]
		btn.text = str(num)
		btn.add_theme_color_override("font_disabled_color", number_colors[num])
		check_win_condition()
	else:
		# Empty space: recursive flood fill
		btn.text = ""
		for dr in [-1, 0, 1]:
			for dc in [-1, 0, 1]:
				var nr = r + dr
				var nc = c + dc
				if nr >= 0 and nr < grid_size and nc >= 0 and nc < grid_size:
					reveal_cell(nr, nc)
		check_win_condition()

func toggle_flag(r: int, c: int):
	flagged[r][c] = not flagged[r][c]
	_play_sfx(flag_stream)
	var btn = cells[r][c]
	if flagged[r][c]:
		btn.text = "F"
		btn.add_theme_color_override("font_color", Color(1, 0, 0, 1))
	else:
		btn.text = ""
		
	# Update mine counter
	var flags_placed = 0
	for row in flagged:
		for flag in row:
			if flag: flags_placed += 1
	mine_label.text = "%02d" % max(0, total_mines - flags_placed)

func trigger_game_over(won: bool):
	game_over = true
	timer_active = false
	
	if won:
		_play_sfx(win_stream)
		face_button.text = "B)" # Sunglasses face
		print("Minesweeper Won!")
		GameStats.casino_balance = round(GameStats.casino_balance + 15.0)
	else:
		_play_sfx(explosion_stream)
		face_button.text = "X(" # Dead face
		# Reveal all mines
		for r in range(grid_size):
			for c in range(grid_size):
				if grid_data[r][c] == -1:
					cells[r][c].text = "*"
					cells[r][c].add_theme_color_override("font_color", Color(1, 0, 0, 1))

func check_win_condition():
	var win = true
	for r in range(grid_size):
		for c in range(grid_size):
			# If a cell is NOT a mine, it MUST be revealed to win
			if grid_data[r][c] != -1 and not revealed[r][c]:
				win = false
				break
	if win:
		trigger_game_over(true)


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
		var val = 0.175 if (fmod(t * freq, 1.0) < 0.5) else -0.175 # Lowered volume by 30%
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
		var val = (randf() - 0.5) * 0.49 * env # Lowered volume by 30%
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
