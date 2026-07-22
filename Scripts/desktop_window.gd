extends Control
class_name DesktopWindow

signal closed
signal minimized
signal focused

@export var title_bar_path: NodePath = "TitleBar"
@onready var title_bar = get_node_or_null(title_bar_path)

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Resize handle controls
var left_border: Control
var right_border: Control
var top_border: Control
var bottom_border: Control
var top_left_corner: Control
var top_right_corner: Control
var bottom_left_corner: Control
var corner_border: Control # bottom-right

var resize_margin: float = 12.0

# Resize state variables
var resizing_left: bool = false
var resizing_right: bool = false
var resizing_top: bool = false
var resizing_bottom: bool = false

var resize_start_size: Vector2 = Vector2.ZERO
var resize_start_pos: Vector2 = Vector2.ZERO
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

	if not left_border:
		left_border = Control.new()
		left_border.name = "LeftBorder"
		left_border.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		left_border.gui_input.connect(_on_left_border_input)
		add_child(left_border)

	if not right_border:
		right_border = Control.new()
		right_border.name = "RightBorder"
		right_border.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		right_border.gui_input.connect(_on_right_border_input)
		add_child(right_border)

	if not top_border:
		top_border = Control.new()
		top_border.name = "TopBorder"
		top_border.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		top_border.gui_input.connect(_on_top_border_input)
		add_child(top_border)

	if not bottom_border:
		bottom_border = Control.new()
		bottom_border.name = "BottomBorder"
		bottom_border.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		bottom_border.gui_input.connect(_on_bottom_border_input)
		add_child(bottom_border)

	if not top_left_corner:
		top_left_corner = Control.new()
		top_left_corner.name = "TopLeftCorner"
		top_left_corner.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		top_left_corner.gui_input.connect(_on_top_left_corner_input)
		add_child(top_left_corner)

	if not top_right_corner:
		top_right_corner = Control.new()
		top_right_corner.name = "TopRightCorner"
		top_right_corner.mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
		top_right_corner.gui_input.connect(_on_top_right_corner_input)
		add_child(top_right_corner)

	if not bottom_left_corner:
		bottom_left_corner = Control.new()
		bottom_left_corner.name = "BottomLeftCorner"
		bottom_left_corner.mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
		bottom_left_corner.gui_input.connect(_on_bottom_left_corner_input)
		add_child(bottom_left_corner)

	if not corner_border:
		corner_border = ResizeGrip.new()
		corner_border.name = "CornerBorder"
		corner_border.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		corner_border.gui_input.connect(_on_corner_border_input)
		add_child(corner_border)

	_update_resize_handles_positions()

func _update_resize_handles_positions():
	if not is_inside_tree() or not is_scalable:
		return
	if not left_border or not right_border or not top_border or not bottom_border:
		return
	if not top_left_corner or not top_right_corner or not bottom_left_corner or not corner_border:
		return

	var m = resize_margin
	var w = size.x
	var h = size.y
	var mid_w = max(0.0, w - 2 * m)
	var mid_h = max(0.0, h - 2 * m)

	# Corners
	top_left_corner.position = Vector2(0, 0)
	top_left_corner.size = Vector2(m, m)

	top_right_corner.position = Vector2(w - m, 0)
	top_right_corner.size = Vector2(m, m)

	bottom_left_corner.position = Vector2(0, h - m)
	bottom_left_corner.size = Vector2(m, m)

	corner_border.position = Vector2(w - m, h - m)
	corner_border.size = Vector2(m, m)

	# Borders
	top_border.position = Vector2(m, 0)
	top_border.size = Vector2(mid_w, m)

	bottom_border.position = Vector2(m, h - m)
	bottom_border.size = Vector2(mid_w, m)

	left_border.position = Vector2(0, m)
	left_border.size = Vector2(m, mid_h)

	right_border.position = Vector2(w - m, m)
	right_border.size = Vector2(m, mid_h)

	# Keep borders on top
	top_left_corner.move_to_front()
	top_right_corner.move_to_front()
	bottom_left_corner.move_to_front()
	corner_border.move_to_front()
	top_border.move_to_front()
	bottom_border.move_to_front()
	left_border.move_to_front()
	right_border.move_to_front()

	corner_border.queue_redraw()

func register_child_margins():
	child_margins.clear()
	var handle_names = ["LeftBorder", "RightBorder", "TopBorder", "BottomBorder", "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "CornerBorder"]
	for child in get_children():
		if child is Control and not child.name in handle_names:
			var left_margin = child.position.x
			var top_margin = child.position.y
			var right_margin = size.x - (child.position.x + child.size.x)
			var bottom_margin = size.y - (child.position.y + child.size.y)
			
			if is_scalable:
				var min_margin = resize_margin + 4.0
				if child.name != "TitleBar" and right_margin < min_margin:
					right_margin = min_margin
				if bottom_margin < min_margin:
					bottom_margin = min_margin
			
			child_margins[child] = {
				"left": left_margin,
				"top": top_margin,
				"right": right_margin,
				"bottom": bottom_margin,
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
			var should_stretch_h = child.name in ["TitleBar", "TextEdit", "TerminalBody", "VideoPanel", "MinesweeperBody", "SnakeBody", "SlotBody", "SettingsBody", "addr_container", "content_panel", "ColorRect", "TerminalBorder", "Panel", "ChatManager", "Option"] \
				or (float(m.orig_width) / float(m.orig_parent_width) > 0.45) \
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
				or (float(m.orig_height) / float(m.orig_parent_height) > 0.45) \
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

func _start_resizing():
	resize_start_size = size
	resize_start_pos = position
	resize_start_mouse_pos = get_global_mouse_position()
	move_to_front()
	focused.emit()

func _on_left_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_left = true
			_start_resizing()
		else:
			resizing_left = false

func _on_right_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_right = true
			_start_resizing()
		else:
			resizing_right = false

func _on_top_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_top = true
			_start_resizing()
		else:
			resizing_top = false

func _on_bottom_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_bottom = true
			_start_resizing()
		else:
			resizing_bottom = false

func _on_top_left_corner_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_top = true
			resizing_left = true
			_start_resizing()
		else:
			resizing_top = false
			resizing_left = false

func _on_top_right_corner_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_top = true
			resizing_right = true
			_start_resizing()
		else:
			resizing_top = false
			resizing_right = false

func _on_bottom_left_corner_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_bottom = true
			resizing_left = true
			_start_resizing()
		else:
			resizing_bottom = false
			resizing_left = false

func _on_corner_border_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			resizing_bottom = true
			resizing_right = true
			_start_resizing()
		else:
			resizing_bottom = false
			resizing_right = false

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
		resizing_left = false
		resizing_right = false
		resizing_top = false
		resizing_bottom = false
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
			
	elif resizing_top or resizing_bottom or resizing_left or resizing_right:
		var current_mouse_pos = get_global_mouse_position()
		var delta_mouse = current_mouse_pos - resize_start_mouse_pos
		var new_size = resize_start_size
		var new_pos = resize_start_pos
		
		var min_w = custom_minimum_size.x if custom_minimum_size.x > 0.0 else 200.0
		var min_h = custom_minimum_size.y if custom_minimum_size.y > 0.0 else 100.0
		
		if resizing_right:
			new_size.x = max(min_w, resize_start_size.x + delta_mouse.x)
		if resizing_left:
			var target_w = max(min_w, resize_start_size.x - delta_mouse.x)
			new_pos.x = resize_start_pos.x + (resize_start_size.x - target_w)
			new_size.x = target_w
			
		if resizing_bottom:
			new_size.y = max(min_h, resize_start_size.y + delta_mouse.y)
		if resizing_top:
			var target_h = max(min_h, resize_start_size.y - delta_mouse.y)
			new_pos.y = resize_start_pos.y + (resize_start_size.y - target_h)
			new_size.y = target_h
			
		if position != new_pos:
			position = new_pos
		if size != new_size:
			size = new_size

func close():
	visible = false
	dragging = false
	resizing_left = false
	resizing_right = false
	resizing_top = false
	resizing_bottom = false
	closed.emit()

func minimize():
	visible = false
	dragging = false
	resizing_left = false
	resizing_right = false
	resizing_top = false
	resizing_bottom = false
	minimized.emit()

func restore():
	visible = true
	move_to_front()
	focused.emit()

class ResizeGrip extends Control:
	func _draw():
		var w = size.x
		var h = size.y
		var shadow_color = Color(0.53, 0.48, 0.44) # Retro dark shadow
		var highlight_color = Color(1.0, 1.0, 1.0) # White highlight
		
		# Ridge 1 (closest to corner, offset by 3px from bottom-right)
		draw_line(Vector2(w - 6, h - 4), Vector2(w - 4, h - 6), shadow_color, 1.0)
		draw_line(Vector2(w - 5, h - 3), Vector2(w - 3, h - 5), highlight_color, 1.0)
		
		# Ridge 2 (middle)
		draw_line(Vector2(w - 10, h - 4), Vector2(w - 4, h - 10), shadow_color, 1.0)
		draw_line(Vector2(w - 9, h - 3), Vector2(w - 3, h - 9), highlight_color, 1.0)
		
		# Ridge 3 (furthest from corner)
		draw_line(Vector2(w - 14, h - 4), Vector2(w - 4, h - 14), shadow_color, 1.0)
		draw_line(Vector2(w - 13, h - 3), Vector2(w - 3, h - 13), highlight_color, 1.0)
