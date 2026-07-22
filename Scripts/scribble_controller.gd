extends Control

@onready var dialog_label = get_node_or_null("../SpeechBubble/DialogLabel")
@onready var next_button = get_node_or_null("../SpeechBubble/NextButton")
@onready var close_bubble_button = get_node_or_null("../SpeechBubble/CloseBubbleButton")

const Day1Pages = [
	"Welcome to your first shift, Inspector! I'm Scribble, your OS assistant. Let's make sure you know how to operate your OS workstation effectively!",
	"First, check the Email client regularly. Corporate will send urgent instructions and important information about upcoming shifts.",
	"Next, double-click the Apparatus Inspector icon. Use this to question the robots.",
	"Lastly, open the Web Browser. You can use it to browse documentation, and reference system specifications.",
	"Stay alert, and good luck tonight!"
]

const Day2Pages = [
	"Welcome back for Shift 2, Inspector! Scribble here with a quick system update for your desktop.",
	"The database in the Apparatus Inspector app has come back online. Compare specs with the Official specs & Core registry website",
	"Thats all, good luck on your second shift!"
]

const Day3Pages = [
	"Shift 3 is under way! I'm still here to help you navigate your desktop tools.",
	"Security intrusions and anomaly spoofing are at peak levels today. Check your emails and terminal commands carefully.",
	"Remember to organize your open windows so you can quickly monitor all active tools.",
	"Stay focused and stay safe tonight!"
]

var active_pages: Array = []
var current_page = 0

func _ready():
	_setup_active_pages()
	_update_page()
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
	
	var parent = get_parent()
	if close_bubble_button:
		close_bubble_button.pressed.connect(func():
			if parent and parent.has_method("close"):
				parent.close()
			else:
				get_parent().visible = false
		)
	
	# Close window on close button or exit
	if parent and parent.has_signal("closed"):
		parent.closed.connect(func():
			current_page = 0
			_setup_active_pages()
			_update_page()
		)

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

func _update_page():
	if not dialog_label or not next_button:
		return
	if active_pages.size() == 0:
		_setup_active_pages()
	dialog_label.text = active_pages[current_page]
	if current_page == active_pages.size() - 1:
		next_button.text = "Close"
	else:
		next_button.text = "Next"

func _on_next_pressed():
	if current_page < active_pages.size() - 1:
		current_page += 1
		_update_page()
	else:
		var parent = get_parent()
		if parent and parent.has_method("close"):
			parent.close()
		else:
			get_parent().visible = false
