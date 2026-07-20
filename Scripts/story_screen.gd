extends Control

@onready var title_label = %Title
@onready var story_label = %StoryLabel
@onready var proceed_button = %ProceedButton
@onready var passcode_input = get_node_or_null("%PasscodeInput")

var stories = {
	1: "=== SHIFT 1 COMPLETE ===\n\nYour first day at Apparatus Robotics has concluded.\n\nLOG REPORT: The testing chamber calibration is complete. However, the facility's security integrity has been compromised: Walter, a heavy security chassis, has escaped containment and is roaming Sector B.\n\nFor Shift 2, alert levels are raised:\n1. ANOMALY DETECTION: Walter will approach the office. Use the PC monitor's CCTV application or search the outer area in 3D using your flashlight (F). Spotting him for 1 second forces a retreat.\n2. CLOSER APPROACH: If ignored, Walter will advance near the glass window. Look out the window and flash your light to scare him away.\n3. DOOR DEFENSE: If Walter reaches the door, he will rattle the handle. You must lock the door using the button on the wall or through the terminal. Lock usage drains power, so unlock it to recharge when safe.\n4. SYSTEM INTRUSIONS: Remote override hacks will now target your PC. Use the terminal to purge them before system files are corrupted.",
	2: "=== SHIFT 2 COMPLETE ===\n\nFacility quarantine status: CRITICAL.\n\nLOG REPORT: The remote intrusions are accelerating, and Walter's behavior has grown highly aggressive. Emergency evacuation protocols have been initiated. The rescue shuttle will arrive at the Sector B landing deck at the end of your next shift.\n\nYou must hold your station for one final shift to secure the remaining robot data:\n1. INCREASED AGGRESSION: Walter will hunt with much shorter cooldowns. Watch the CCTV and the window closely.\n2. FREQUENT HACKS: Remote integrity anomalies will target the PC at a significantly higher rate. Maintain WiFi power controls and purge intrusions immediately.\n3. CRITICAL QUOTA: Meet your final quota of 5 inspected units to secure the archives and initiate shuttle launch."
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
