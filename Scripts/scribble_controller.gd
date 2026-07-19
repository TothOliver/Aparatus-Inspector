extends Control

@onready var dialog_label = get_node_or_null("../SpeechBubble/DialogLabel")
@onready var next_button = get_node_or_null("../SpeechBubble/NextButton")
@onready var close_bubble_button = get_node_or_null("../SpeechBubble/CloseBubbleButton")

const PAGES = [
	"Welcome back to another shift, Inspector! I'm Scribble, your OS assistant. Let's make sure you're up to speed on the tools at your disposal tonight.",
	"First, check the Email client regularly. Corporate will send urgent instructions and importand information about upcoming shifts.",
	"Next, double-click the Apparatus Inspector icon. Use this to monitor core stability. It's offline for Calibration right now, but you can still run manual diagnostics!",
	"Lastly, open the Web Browser. You can use it to browse documentation, and reference system specifications",
	"Stay alert, and good luck tonight!"
]

var current_page = 0

func _ready():
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
			_update_page()
		)

func _update_page():
	if not dialog_label or not next_button:
		return
	dialog_label.text = PAGES[current_page]
	if current_page == PAGES.size() - 1:
		next_button.text = "Close"
	else:
		next_button.text = "Next"

func _on_next_pressed():
	if current_page < PAGES.size() - 1:
		current_page += 1
		_update_page()
	else:
		var parent = get_parent()
		if parent and parent.has_method("close"):
			parent.close()
		else:
			get_parent().visible = false
