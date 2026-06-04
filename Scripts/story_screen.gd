extends Control

@onready var title_label = %Title
@onready var story_label = %StoryLabel
@onready var proceed_button = %ProceedButton
@onready var passcode_input = get_node_or_null("%PasscodeInput")

var stories = {
	1: "=== SHIFT 1 COMPLETE ===\n\nYour first day at Apparatus Robotics has concluded.\n\nLOG REPORT: The testing chamber has successfully calibrated its neural integrity matrices. However, local system logs contain warning signs: Walter, a heavy security chassis, has gone offline and escaped containment in the lower warehouse.\n\nAlert level has been raised. Sensor reports suggest high-level acoustic patterns roaming the hallway outside Sector B.\n\nKeep your ceiling lights off and sit beneath the desk if safety is compromised.",
	2: "=== SHIFT 2 COMPLETE ===\n\nFacility quarantine status: CRITICAL.\n\nLOG REPORT: Walter has breached Sector B corridor and is actively hunting. The terminal system has been targeted by remote integrity anomalies, causing frequent system override hacks.\n\nGeneral evacuation has been ordered. The rescue shuttle is scheduled to arrive at Sector B landing deck in 24 hours. You must hold your station for one final shift to secure the remaining data archives.\n\nRemember to lock the door manually or cover the glass window if the unit approaches."
}

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if has_node("CRTOverlay"):
		$CRTOverlay.visible = GameStats.crt_effect_enabled
	
	if passcode_input:
		passcode_input.visible = false
		
	var completed_day = GameStats.current_day
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
	GameStats.current_day += 1
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Game3D.tscn")
