extends Control

@onready var dialog_label = get_node_or_null("../SpeechBubble/DialogLabel")
@onready var next_button = get_node_or_null("../SpeechBubble/NextButton")
@onready var close_bubble_button = get_node_or_null("../SpeechBubble/CloseBubbleButton")

const Day1Pages = [
	"Welcome to your first shift, Inspector! I'm Scribble, your OS assistant. Let's make sure you know how to operate your OS workstation effectively!",
	"First, check the Mail app regularly. Corporate will send urgent instructions and important information about upcoming shifts.",
	"Next, click the Apparatus Inspector icon. Use this to question the robots.",
	"Lastly, open the Apparatus Explorer. You can use it to browse documentation, and reference system specifications.",
	"Stay alert, and good luck tonight!"
]

const Day2Pages = [
	"Welcome back for Shift 2, Inspector! Scribble here with a quick system update for your workstation.",
	"The core specs on the Inspector app are now locked by default. Type 'scan' in the AE-DOS terminal for each unit to retrieve what the robot ACTUALLY has.",
	"Then open the Web Browser to www.robot-factory.corp/registry to compare against what the robot SHOULD have!",
	"Stay vigilant and good luck on your second shift!"
]

const Day3Pages = [
	"Shift 3 is under way! I'm still here to help you navigate your desktop tools.",
	"Security intrusions and fake robot specs are at peak levels today. Check your Mail carefully.",
	"Remember to organize your open windows so you can quickly monitor all active tools.",
	"Stay focused and stay safe tonight!"
]

var active_pages: Array = []
var current_page = 0
var is_typing: bool = false
var typing_speed: float = 75.0 # characters per second
var typing_progress: float = 0.0
var target_text: String = ""

func _ready():
	_setup_active_pages()
	_update_page()
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	
	var parent = get_parent()
	if parent:
		if close_bubble_button:
			close_bubble_button.pressed.connect(func():
				if parent.has_method("close"):
					parent.close()
				else:
					parent.visible = false
			)
		
		# Preserve current page when un-minimizing / restoring window
		parent.visibility_changed.connect(func():
			if parent.visible:
				if target_text == "" or dialog_label.text == "":
					_update_page()
				elif is_typing and dialog_label:
					dialog_label.visible_characters = int(typing_progress)
				elif not is_typing and dialog_label:
					dialog_label.visible_characters = -1
		)
		
		if parent.has_signal("closed"):
			parent.closed.connect(func():
				current_page = 0
				_setup_active_pages()
				_update_page()
			)

func _process(delta):
	if is_typing and dialog_label:
		typing_progress += delta * typing_speed
		var count = int(typing_progress)
		if count >= target_text.length():
			dialog_label.visible_characters = -1
			is_typing = false
		else:
			dialog_label.visible_characters = count

func _setup_active_pages():
	var day = GameStats.current_day
	match day:
		1:
			active_pages = Day1Pages
		2:
			active_pages = Day2Pages
		3:
			active_pages = Day3Pages
		_:
			active_pages = Day1Pages

func _prewrap_text(raw_text: String) -> String:
	if not dialog_label:
		return raw_text
	var font = dialog_label.get_theme_font("font")
	var font_size = dialog_label.get_theme_font_size("font_size")
	if not font:
		return raw_text
		
	var max_width = dialog_label.size.x
	if max_width <= 0:
		max_width = 302.0
	max_width -= 6.0
	
	var lines = raw_text.split("\n")
	var result_lines: Array[String] = []
	
	for line in lines:
		var words = line.split(" ")
		var current_line = ""
		for word in words:
			if word == "":
				continue
			var test_line = (current_line + " " + word).strip_edges()
			var string_size = font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			if string_size.x <= max_width or current_line == "":
				current_line = test_line
			else:
				result_lines.append(current_line)
				current_line = word
		if current_line != "":
			result_lines.append(current_line)
			
	return "\n".join(result_lines)

func _update_page():
	if not dialog_label or not next_button:
		return
	if active_pages.size() == 0:
		_setup_active_pages()
	
	var raw_page_text = active_pages[current_page]
	target_text = _prewrap_text(raw_page_text)
	dialog_label.text = target_text
	dialog_label.visible_characters = 0
	is_typing = true
	typing_progress = 0.0
	
	if current_page == active_pages.size() - 1:
		next_button.text = "Close"
	else:
		next_button.text = "Next"

func _on_next_pressed():
	if is_typing:
		# Complete current page typing immediately
		if dialog_label:
			dialog_label.visible_characters = -1
		is_typing = false
		return
		
	if current_page < active_pages.size() - 1:
		current_page += 1
		_update_page()
	else:
		var parent = get_parent()
		if parent and parent.has_method("close"):
			parent.close()
		else:
			get_parent().visible = false
