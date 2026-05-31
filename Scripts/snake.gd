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

func _ready():
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
		score += 10
		score_label.text = "Score: " + str(score)
		spawn_food()
	else:
		# Remove tail segment if food not eaten
		snake.pop_back()
		
	game_area.queue_redraw()

func end_game():
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
