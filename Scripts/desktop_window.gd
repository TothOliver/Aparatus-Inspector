extends Control
class_name DesktopWindow

signal closed
signal minimized
signal focused

@export var title_bar_path: NodePath = "TitleBar"
@onready var title_bar = get_node_or_null(title_bar_path)

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Resize variables
var right_border: Control
var bottom_border: Control
var corner_border: Control

var resize_margin: float = 8.0

var resizing_right: bool = false
var resizing_bottom: bool = false
var resizing_corner: bool = false
var resize_start_size: Vector2 = Vector2.ZERO
var resize_start_mouse_pos: Vector2 = Vector2.ZERO

var child_margins: Dictionary = {}
var _margins_registered: bool = false

@export var is_scalable: bool = false

func _ready():
	if title_bar:
		title_bar.gui_input.connect(_on_title_bar_gui_input)
		var close_btn = title_bar.get_node_or_null("CloseButton")
		if close_btn and not close_btn.pressed.is_connected(close):
			close_btn.pressed.connect(close)
	
	# Bring to front on clicking anywhere on the window
	gui_input.connect(_on_window_gui_input)
	
	if is_scalable:
		# Set up resize handles
		_setup_resize_handles()
		
		# Connect resized signal
		resized.connect(_on_window_resized)

func _setup_resize_handles():
	if not is_scalable:
		return
	if not right_border:
		# Right border is a thin vertical strip on the right side
		right_border = Control.new()
		right_border.name = "RightBorder"
		right_border.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		right_border.gui_input.connect(_on_right_border_input)
		add_child(right_border)
	
	if not bottom_border:
		# Bottom border is a thin horizontal strip on the bottom side
		bottom_border = Control.new()
		bottom_border.name = "BottomBorder"
		bottom_border.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		bottom_border.gui_input.connect(_on_bottom_border_input)
		add_child(bottom_border)
	
	if not corner_border:
		# Corner border is a small square on the bottom right corner
		corner_border = Control.new()
		corner_border.name = "CornerBorder"
		corner_border.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		corner_border.gui_input.connect(_on_corner_border_input)
		add_child(corner_border)
	
	_update_resize_handles_positions()

func _update_resize_handles_positions():
	if not is_inside_tree():
		return
	if not right_border or not bottom_border or not corner_border:
		return
	right_border.position = Vector2(size.x - resize_margin, 0)
	right_border.size = Vector2(resize_margin, max(0, size.y - resize_margin))
	
	bottom_border.position = Vector2(0, size.y - resize_margin)
	bottom_border.size = Vector2(max(0, size.x - resize_margin), resize_margin)
	
	corner_border.position = Vector2(size.x - resize_margin, size.y - resize_margin)
	corner_border.size = Vector2(resize_margin, resize_margin)
	
	# Keep borders on top
	right_border.move_to_front()
	bottom_border.move_to_front()
	corner_border.move_to_front()

func register_child_margins():
	child_margins.clear()
	for child in get_children():
		if child is Control and not child.name in ["RightBorder", "BottomBorder", "CornerBorder"]:
			child_margins[child] = {
				"left": child.position.x,
				"top": child.position.y,
				"right": size.x - (child.position.x + child.size.x),
				"bottom": size.y - (child.position.y + child.size.y),
				"orig_width": child.size.x,
				"orig_height": child.size.y,
				"orig_parent_width": size.x,
				"orig_parent_height": size.y
			}

func update_child_positions():
	for child in child_margins.keys():
		if is_instance_valid(child) and child is Control:
			var m = child_margins[child]
			
			# Horizontal resizing
			var should_stretch_h = child.name in ["TitleBar", "TextEdit", "TerminalBody", "VideoPanel", "MinesweeperBody", "SnakeBody", "SlotBody", "SettingsBody", "addr_container", "content_panel", "ColorRect", "TerminalBorder", "Panel"] \
				or (m.orig_width / m.orig_parent_width > 0.45) \
				or (m.left < 80 and m.right < 80)
			
			if should_stretch_h:
				child.position.x = m.left
				child.size.x = max(10, size.x - m.left - m.right)
			else:
				if m.right < m.left:
					child.position.x = size.x - m.right - m.orig_width
				else:
					child.position.x = m.left
				child.size.x = m.orig_width
			
			# Vertical resizing
			var should_stretch_v = child.name in ["TextEdit", "TerminalBody", "VideoPanel", "MinesweeperBody", "SnakeBody", "SlotBody", "SettingsBody", "content_panel", "ColorRect", "TerminalBorder", "Panel"] \
				or (m.orig_height / m.orig_parent_height > 0.45) \
				or (m.top < 80 and m.bottom < 80)
			
			if should_stretch_v:
				child.position.y = m.top
				child.size.y = max(10, size.y - m.top - m.bottom)
			else:
				if m.bottom < m.top:
					child.position.y = size.y - m.bottom - m.orig_height
				else:
					child.position.y = m.top
				child.size.y = m.orig_height
			
			# Special handling for TitleBar to move the CloseButton
			if child.name == "TitleBar":
				var close_btn = child.get_node_or_null("CloseButton")
				if close_btn and close_btn is Control:
					close_btn.position.x = child.size.x - close_btn.size.x - 6

func _on_window_resized():
	if not _margins_registered:
		return
	update_child_positions()
	_update_resize_handles_positions()

func _on_window_resized_internal():
	_on_window_resized()

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

func _on_right_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_right = true
			resize_start_size = size
			resize_start_mouse_pos = get_global_mouse_position()
			move_to_front()
			focused.emit()
		else:
			resizing_right = false

func _on_bottom_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_bottom = true
			resize_start_size = size
			resize_start_mouse_pos = get_global_mouse_position()
			move_to_front()
			focused.emit()
		else:
			resizing_bottom = false

func _on_corner_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_corner = true
			resize_start_size = size
			resize_start_mouse_pos = get_global_mouse_position()
			move_to_front()
			focused.emit()
		else:
			resizing_corner = false

func _process(_delta):
	# Register margins on first process tick to ensure all subclasses ready
	if not _margins_registered:
		register_child_margins()
		if is_scalable:
			_setup_resize_handles()
			if not resized.is_connected(_on_window_resized):
				resized.connect(_on_window_resized)
		_margins_registered = true
		_update_resize_handles_positions()
		update_child_positions()
		
	# Safety release in case mouse up occurred outside focus
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		resizing_right = false
		resizing_bottom = false
		resizing_corner = false
		dragging = false
		
	if dragging:
		var parent_control = get_parent_control()
		if parent_control:
			var mouse_pos = parent_control.get_local_mouse_position()
			position = mouse_pos - drag_offset
			
			# Clamp to stay partially inside screen boundaries
			var size_limit = parent_control.size
			position.x = clamp(position.x, -size.x + 50, size_limit.x - 50)
			position.y = clamp(position.y, 0, size_limit.y - 30)
			
	elif resizing_right or resizing_bottom or resizing_corner:
		var current_mouse_pos = get_global_mouse_position()
		var delta_mouse = current_mouse_pos - resize_start_mouse_pos
		var new_size = resize_start_size
		
		var min_w = 200.0
		var min_h = 100.0
		
		if resizing_right or resizing_corner:
			new_size.x = max(min_w, resize_start_size.x + delta_mouse.x)
		if resizing_bottom or resizing_corner:
			new_size.y = max(min_h, resize_start_size.y + delta_mouse.y)
			
		if size != new_size:
			size = new_size

func close():
	visible = false
	dragging = false
	resizing_right = false
	resizing_bottom = false
	resizing_corner = false
	closed.emit()

func minimize():
	visible = false
	dragging = false
	resizing_right = false
	resizing_bottom = false
	resizing_corner = false
	minimized.emit()

func restore():
	visible = true
	move_to_front()
	focused.emit()
