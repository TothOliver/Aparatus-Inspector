extends Control

@onready var grid_container = $GridFrame/GridContainer if has_node("GridFrame/GridContainer") else $GridContainer
@onready var mine_label = get_node_or_null("HeaderPanel/MinePanel/MineLabel") if has_node("HeaderPanel/MinePanel/MineLabel") else get_node_or_null("HeaderPanel/MineLabel")
@onready var face_button = $HeaderPanel/FaceButton
@onready var timer_label = get_node_or_null("HeaderPanel/TimerPanel/TimerLabel") if has_node("HeaderPanel/TimerPanel/TimerLabel") else get_node_or_null("HeaderPanel/TimerLabel")

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

# Retro colors for mine counts (matching classic Minesweeper)
var number_colors = {
	1: Color(0, 0, 1),        # Blue
	2: Color(0, 0.5, 0),      # Dark Green
	3: Color(1, 0, 0),        # Red
	4: Color(0, 0, 0.5),      # Dark Navy
	5: Color(0.5, 0, 0),      # Maroon
	6: Color(0, 0.5, 0.5),    # Teal
	7: Color(0, 0, 0),        # Black
	8: Color(0.5, 0.5, 0.5)   # Grey
}

enum FaceState { IDLE, SURPRISED, DEAD, WON }
var face_state: FaceState = FaceState.IDLE
var face_canvas: Control

func _ready():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.volume_db = -10.0
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	click_stream = _generate_click_sound()
	flag_stream = _generate_flag_sound()
	explosion_stream = _generate_explosion_sound()
	win_stream = _generate_win_sound()
	
	_setup_unlit_labels()
	_setup_face_canvas()
	
	if face_button:
		if not face_button.pressed.is_connected(reset_game):
			face_button.pressed.connect(reset_game)
	reset_game()

func _setup_unlit_labels():
	var mine_panel = get_node_or_null("HeaderPanel/MinePanel")
	if mine_panel and mine_label:
		if not mine_panel.has_node("MineUnlitLabel"):
			var unlit = Label.new()
			unlit.name = "MineUnlitLabel"
			unlit.text = "888"
			unlit.add_theme_color_override("font_color", Color(0.25, 0, 0, 1))
			unlit.add_theme_font_override("font", mine_label.get_theme_font("font"))
			unlit.add_theme_font_size_override("font_size", mine_label.get_theme_font_size("font_size"))
			unlit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			unlit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			unlit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			mine_panel.add_child(unlit)
			mine_panel.move_child(unlit, mine_label.get_index())
			
	var timer_panel = get_node_or_null("HeaderPanel/TimerPanel")
	if timer_panel and timer_label:
		if not timer_panel.has_node("TimerUnlitLabel"):
			var unlit = Label.new()
			unlit.name = "TimerUnlitLabel"
			unlit.text = "888"
			unlit.add_theme_color_override("font_color", Color(0.25, 0, 0, 1))
			unlit.add_theme_font_override("font", timer_label.get_theme_font("font"))
			unlit.add_theme_font_size_override("font_size", timer_label.get_theme_font_size("font_size"))
			unlit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			unlit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			unlit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			timer_panel.add_child(unlit)
			timer_panel.move_child(unlit, timer_label.get_index())

func _setup_face_canvas():
	if not face_button:
		return
	face_button.text = ""
	if face_button.has_node("FaceCanvas"):
		face_canvas = face_button.get_node("FaceCanvas")
	else:
		face_canvas = Control.new()
		face_canvas.name = "FaceCanvas"
		face_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		face_canvas.draw.connect(_draw_face)
		face_button.add_child(face_canvas)

func _set_face(s: FaceState):
	face_state = s
	if face_canvas:
		face_canvas.queue_redraw()

func _draw_face():
	if not face_canvas:
		return
	var sz = face_canvas.size
	var center = sz / 2.0
	var r = min(sz.x, sz.y) * 0.38
	
	# Base yellow circle
	face_canvas.draw_circle(center, r, Color(1.0, 0.85, 0.0))
	face_canvas.draw_arc(center, r, 0, TAU, 32, Color(0, 0, 0), 1.5)
	
	match face_state:
		FaceState.IDLE:
			face_canvas.draw_circle(center + Vector2(-r * 0.35, -r * 0.25), 1.8, Color(0, 0, 0))
			face_canvas.draw_circle(center + Vector2(r * 0.35, -r * 0.25), 1.8, Color(0, 0, 0))
			_draw_arc_polyline(center + Vector2(0, r * 0.05), r * 0.5, 0.2 * PI, 0.8 * PI, Color(0, 0, 0), 1.5)
		FaceState.SURPRISED:
			face_canvas.draw_circle(center + Vector2(-r * 0.35, -r * 0.25), 2.0, Color(0, 0, 0))
			face_canvas.draw_circle(center + Vector2(r * 0.35, -r * 0.25), 2.0, Color(0, 0, 0))
			face_canvas.draw_arc(center + Vector2(0, r * 0.25), r * 0.28, 0, TAU, 16, Color(0, 0, 0), 1.5)
		FaceState.DEAD:
			_draw_x(center + Vector2(-r * 0.35, -r * 0.25), 3.0, Color(0, 0, 0))
			_draw_x(center + Vector2(r * 0.35, -r * 0.25), 3.0, Color(0, 0, 0))
			_draw_arc_polyline(center + Vector2(0, r * 0.5), r * 0.5, 1.2 * PI, 1.8 * PI, Color(0, 0, 0), 1.5)
		FaceState.WON:
			var glass_rect = Rect2(center + Vector2(-r * 0.7, -r * 0.45), Vector2(r * 1.4, r * 0.45))
			face_canvas.draw_rect(glass_rect, Color(0, 0, 0))
			face_canvas.draw_line(center + Vector2(-r * 0.5, -r * 0.35), center + Vector2(-r * 0.2, -r * 0.2), Color(1, 1, 1), 1.0)
			_draw_arc_polyline(center + Vector2(0, r * 0.05), r * 0.55, 0.15 * PI, 0.85 * PI, Color(0, 0, 0), 1.5)

func _draw_arc_polyline(c: Vector2, radius: float, start_a: float, end_a: float, color: Color, width: float):
	var points = PackedVector2Array()
	var steps = 16
	for i in range(steps + 1):
		var a = start_a + (end_a - start_a) * (float(i) / float(steps))
		points.append(c + Vector2(cos(a), sin(a)) * radius)
	face_canvas.draw_polyline(points, color, width)

func _draw_x(c: Vector2, sz: float, color: Color):
	face_canvas.draw_line(c - Vector2(sz, sz), c + Vector2(sz, sz), color, 1.5)
	face_canvas.draw_line(c + Vector2(-sz, sz), c + Vector2(sz, -sz), color, 1.5)

func _process(delta):
	if timer_active:
		time_elapsed += delta
		if timer_label:
			timer_label.text = "%03d" % min(999, int(time_elapsed))

func _set_cell_icon(btn: Button, icon_type: String):
	if btn.has_node("CellIcon"):
		btn.get_node("CellIcon").queue_free()
		
	if icon_type == "":
		return
		
	var canvas = Control.new()
	canvas.name = "CellIcon"
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if icon_type == "mine" or icon_type == "mine_hit":
		canvas.draw.connect(func():
			var center = canvas.size / 2.0
			var r = 4.5
			canvas.draw_line(center - Vector2(6, 0), center + Vector2(6, 0), Color(0, 0, 0), 1.5)
			canvas.draw_line(center - Vector2(0, 6), center + Vector2(0, 6), Color(0, 0, 0), 1.5)
			canvas.draw_line(center - Vector2(4, 4), center + Vector2(4, 4), Color(0, 0, 0), 1.5)
			canvas.draw_line(center - Vector2(-4, 4), center + Vector2(4, -4), Color(0, 0, 0), 1.5)
			canvas.draw_circle(center, r, Color(0, 0, 0))
			canvas.draw_circle(center + Vector2(-1.5, -1.5), 1.0, Color(1, 1, 1))
		)
	elif icon_type == "flag":
		canvas.draw.connect(func():
			var center = canvas.size / 2.0
			canvas.draw_line(center + Vector2(-2, 5), center + Vector2(-2, -5), Color(0, 0, 0), 1.5)
			var pts = PackedVector2Array([
				center + Vector2(-2, -5),
				center + Vector2(5, -2),
				center + Vector2(-2, 1)
			])
			canvas.draw_colored_polygon(pts, Color(1, 0, 0))
			canvas.draw_line(center + Vector2(-4, 5), center + Vector2(1, 5), Color(0, 0, 0), 1.5)
		)
		
	btn.add_child(canvas)

func reset_game():
	if not grid_container:
		return
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
	if timer_label:
		timer_label.text = "000"
	if mine_label:
		mine_label.text = "%03d" % total_mines
	_set_face(FaceState.IDLE)
	
	for r in range(grid_size):
		var row_cells = []
		var row_data = []
		var row_rev = []
		var row_flag = []
		for c in range(grid_size):
			var button = Button.new()
			button.custom_minimum_size = Vector2(24, 24)
			button.size = Vector2(24, 24)
			button.add_theme_font_override("font", load("res://RetroWindowsGUI/windows-bold[1].ttf"))
			button.add_theme_font_size_override("font_size", 14)
			var normal_style = load("res://RetroWindowsGUI/StyleBox_Button_Normal.tres")
			var hover_style = load("res://RetroWindowsGUI/StyleBox_Button_Hover.tres")
			var pressed_style = load("res://RetroWindowsGUI/StyleBox_Button_Pressed.tres")
			button.add_theme_stylebox_override("normal", normal_style)
			button.add_theme_stylebox_override("hover", hover_style)
			button.add_theme_stylebox_override("pressed", pressed_style)
			button.add_theme_stylebox_override("focus", hover_style)
			
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
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_set_face(FaceState.SURPRISED)
			else:
				if not game_over:
					_set_face(FaceState.IDLE)
				if not flagged[r][c] and not revealed[r][c]:
					_play_sfx(click_stream)
					if first_click:
						generate_mines(r, c)
						first_click = false
						timer_active = true
					reveal_cell(r, c)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if not revealed[r][c]:
				toggle_flag(r, c)

func generate_mines(start_r: int, start_c: int):
	var mine_positions = []
	var attempts = 0
	
	while mine_positions.size() < total_mines and attempts < 1000:
		attempts += 1
		var r = randi() % grid_size
		var c = randi() % grid_size
		
		if abs(r - start_r) <= 1 and abs(c - start_c) <= 1:
			continue
			
		var pos = Vector2i(r, c)
		if not pos in mine_positions:
			mine_positions.append(pos)
			grid_data[r][c] = -1
			
	for r in range(grid_size):
		for c in range(grid_size):
			if grid_data[r][c] == -1:
				continue
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
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.78, 0.78, 0.78, 1)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_color = Color(0.5, 0.5, 0.5, 1)
	btn.add_theme_stylebox_override("disabled", style_box)

	if grid_data[r][c] == -1:
		style_box.bg_color = Color(1.0, 0.0, 0.0, 1)
		btn.text = ""
		_set_cell_icon(btn, "mine_hit")
		trigger_game_over(false)
	elif grid_data[r][c] > 0:
		var num = grid_data[r][c]
		btn.text = str(num)
		btn.add_theme_color_override("font_disabled_color", number_colors[num])
		check_win_condition()
	else:
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
		btn.text = ""
		_set_cell_icon(btn, "flag")
	else:
		btn.text = ""
		_set_cell_icon(btn, "")
		
	var flags_placed = 0
	for row in flagged:
		for flag in row:
			if flag: flags_placed += 1
	if mine_label:
		mine_label.text = "%03d" % max(0, total_mines - flags_placed)

func trigger_game_over(won: bool):
	game_over = true
	timer_active = false
	
	if won:
		_play_sfx(win_stream)
		_set_face(FaceState.WON)
		GameStats.casino_balance = round(GameStats.casino_balance + 15.0)
	else:
		_play_sfx(explosion_stream)
		_set_face(FaceState.DEAD)
		for r in range(grid_size):
			for c in range(grid_size):
				if grid_data[r][c] == -1 and not revealed[r][c]:
					cells[r][c].text = ""
					_set_cell_icon(cells[r][c], "mine")

func check_win_condition():
	var win = true
	for r in range(grid_size):
		for c in range(grid_size):
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
	var num_samples = 400
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
	var num_samples = 900
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = (1.0 - t / 0.08)
		var freq = 400.0 + t * 2500.0
		var val = 0.175 if (fmod(t * freq, 1.0) < 0.5) else -0.175
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_explosion_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 6000
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-8.0 * t)
		var val = (randf() - 0.5) * 0.49 * env
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func _generate_win_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 7000
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 523.25
		if t > 0.45:
			freq = 1046.50
		elif t > 0.3:
			freq = 783.99
		elif t > 0.15:
			freq = 659.25
		var env = exp(-6.0 * (t - 0.45 if t > 0.45 else (t - 0.3 if t > 0.3 else (t - 0.15 if t > 0.15 else t))))
		var val = 0.35 if (fmod(t * freq, 1.0) < 0.5) else -0.35
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream
