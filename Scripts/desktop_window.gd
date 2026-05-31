extends Control
class_name DesktopWindow

signal closed
signal minimized
signal focused

@export var title_bar_path: NodePath = "TitleBar"
@onready var title_bar = get_node_or_null(title_bar_path)

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	if title_bar:
		title_bar.gui_input.connect(_on_title_bar_gui_input)
	
	# Bring to front on clicking anywhere on the window
	gui_input.connect(_on_window_gui_input)

func _on_title_bar_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_local_mouse_position()
				move_to_front()
				focused.emit()
			else:
				dragging = false

func _on_window_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		move_to_front()
		focused.emit()

func _process(_delta):
	if dragging:
		var parent_control = get_parent_control()
		if parent_control:
			var mouse_pos = parent_control.get_local_mouse_position()
			position = mouse_pos - drag_offset
			
			# Clamp to stay partially inside screen boundaries
			var size_limit = parent_control.size
			position.x = clamp(position.x, -size.x + 50, size_limit.x - 50)
			position.y = clamp(position.y, 0, size_limit.y - 30)

func close():
	visible = false
	dragging = false
	closed.emit()

func minimize():
	visible = false
	dragging = false
	minimized.emit()

func restore():
	visible = true
	move_to_front()
	focused.emit()
