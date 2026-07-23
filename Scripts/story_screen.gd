extends Control

@onready var title_label = %Title
@onready var story_label = %StoryLabel
@onready var proceed_button = %ProceedButton
@onready var passcode_input = get_node_or_null("%PasscodeInput")

var stories = {
	1: "=== SHIFT 1 COMPLETE ===\n\nCalibration complete.\n\nINCIDENT REPORT: Unit #3 (Walter) has broken containment locks and escaped into Sector B. Facility alert status raised to YELLOW.",
	2: "=== SHIFT 2 COMPLETE ===\n\nFacility Quarantine: CRITICAL.\n\nINCIDENT REPORT: Remote intrusions are escalating and containment breaches remain active. The evacuation shuttle will arrive at the end of Shift 3.\n\nHold your station for one final shift."
}

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if has_node("CRTOverlay"):
		$CRTOverlay.visible = GameStats.crt_effect_enabled
	
	if passcode_input:
		passcode_input.visible = false
		
	var completed_day = GameStats.current_day - 1
	if completed_day in stories:
		title_label.text = "Shift " + str(completed_day) + " Completed"
		story_label.text = stories[completed_day]
		proceed_button.text = "Begin Shift " + str(completed_day + 1)
	else:
		title_label.text = "Shift Completed"
		story_label.text = "You have completed the shift successfully."
		proceed_button.text = "Next Day"
		
	proceed_button.pressed.connect(_on_proceed_pressed)

func _on_proceed_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file.call_deferred("res://Scenes/Game3D.tscn")
