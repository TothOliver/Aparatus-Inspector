extends Control

@onready var status_label = %StatusLabel
@onready var prompt_label = %PromptLabel
@onready var passcode_input = %PasscodeInput
@onready var verify_button = %VerifyButton
@onready var feedback_label = %FeedbackLabel

var is_processing_verification: bool = false

func _ready():
	verify_button.pressed.connect(_on_verify_pressed)
	passcode_input.text_submitted.connect(_on_passcode_submitted)
	feedback_label.text = ""
	_update_ui()

func _process(_delta):
	_update_ui()

func get_day_manager() -> Node:
	# Try absolute viewport path first
	var dm = get_node_or_null("/root/Game3D/SubViewportContainer/SubViewport/Control2/DayManager")
	if dm:
		return dm
	# Fallback sibling lookups
	var parent_win = get_parent() # ShiftVerifyWindow
	if parent_win:
		var grand = parent_win.get_parent() # Control2
		if grand and grand.has_node("DayManager"):
			return grand.get_node("DayManager")
	return null

func _update_ui():
	if is_processing_verification:
		return
		
	var dm = get_day_manager()
	if not dm:
		status_label.text = "STATUS: ERROR - DAY MANAGER OFFLINE"
		verify_button.disabled = true
		passcode_input.editable = false
		return
		
	var day = GameStats.current_day
	var processed = dm.processed_today
	var quota = 3
	if day in dm.day_configs:
		quota = dm.day_configs[day].quota
		
	var quota_met = processed >= quota
	
	if day == 1:
		status_label.text = "STATUS: SHIFT 1 - QUOTA (%d/%d)" % [processed, quota]
		if quota_met:
			status_label.add_theme_color_override("font_color", Color(0, 0.5, 0)) # Green
			prompt_label.text = "Enter Shift 2 Authorization Passcode:"
			passcode_input.editable = true
			verify_button.disabled = false
		else:
			status_label.add_theme_color_override("font_color", Color(0.8, 0, 0)) # Red
			prompt_label.text = "Complete your quota to authorize exit."
			passcode_input.editable = false
			verify_button.disabled = true
	elif day == 2:
		status_label.text = "STATUS: SHIFT 2 - QUOTA (%d/%d)" % [processed, quota]
		if quota_met:
			status_label.add_theme_color_override("font_color", Color(0, 0.5, 0)) # Green
			prompt_label.text = "Enter Shift 3 Bypass Passcode:"
			passcode_input.editable = true
			verify_button.disabled = false
		else:
			status_label.add_theme_color_override("font_color", Color(0.8, 0, 0)) # Red
			prompt_label.text = "Complete your quota to authorize exit."
			passcode_input.editable = false
			verify_button.disabled = true
	elif day == 3:
		status_label.text = "STATUS: SHIFT 3 - QUOTA (%d/%d)" % [processed, quota]
		if quota_met:
			status_label.add_theme_color_override("font_color", Color(0, 0.5, 0)) # Green
			prompt_label.text = "No passcode required. Final shift ready."
			passcode_input.editable = false
			passcode_input.placeholder_text = "N/A"
			verify_button.text = "Evacuate & Submit Archives"
			verify_button.disabled = false
		else:
			status_label.add_theme_color_override("font_color", Color(0.8, 0, 0)) # Red
			prompt_label.text = "Complete your quota to authorize exit."
			passcode_input.editable = false
			verify_button.disabled = true

func _on_passcode_submitted(_text: String):
	_on_verify_pressed()

func _on_verify_pressed():
	if is_processing_verification:
		return
		
	var dm = get_day_manager()
	if not dm:
		return
		
	var day = GameStats.current_day
	var entered_code = passcode_input.text.strip_edges()
	
	var correct = false
	if day == 1:
		correct = (entered_code == "2984")
	elif day == 2:
		correct = (entered_code == "8841")
	elif day == 3:
		correct = true # No passcode required for final day
		
	if correct:
		is_processing_verification = true
		feedback_label.text = "ACCESS GRANTED. AUTHORIZING SHIFT EXIT..."
		feedback_label.add_theme_color_override("font_color", Color(0, 0.5, 0)) # Green
		verify_button.disabled = true
		passcode_input.editable = false
		
		# Close the window visuals smoothly before ending day
		await get_tree().create_timer(1.2).timeout
		
		# Trigger the DayManager shift completion sequence
		dm.end_day()
	else:
		feedback_label.text = "ACCESS DENIED - INVALID CODE"
		feedback_label.add_theme_color_override("font_color", Color(0.8, 0, 0)) # Red
		passcode_input.text = ""
		
		# Clear feedback label after short timeout
		await get_tree().create_timer(2.0).timeout
		if not is_processing_verification:
			feedback_label.text = ""
