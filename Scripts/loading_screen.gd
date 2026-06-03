extends Control

@onready var progress_bar = %ProgressBar
@onready var status_label = %StatusLabel
@onready var crt_overlay = %CRTOverlay

var target_path: String = ""
var progress: Array = [0.0]
var status_steps: Array = [
	"Initializing system components...",
	"Connecting diagnostic telemetry...",
	"Loading chamber geometry...",
	"Caching AI evaluation metrics...",
	"Establishing remote terminal link...",
	"Finalizing setup..."
]
var step_index: int = 0
var time_accum: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if crt_overlay:
		crt_overlay.add_to_group("CRTOverlays")
		crt_overlay.visible = GameStats.crt_effect_enabled
		
	target_path = GameStats.target_scene_path
	if target_path.is_empty():
		target_path = "res://Scenes/MainMenu.tscn" # Fallback
		
	# Start background loading
	var err = ResourceLoader.load_threaded_request(target_path)
	if err != OK:
		status_label.text = "Error: Failed to request scene load."
		set_process(false)

func _process(delta: float) -> void:
	time_accum += delta
	
	# Rotate status labels slowly
	if time_accum >= 0.4:
		time_accum = 0.0
		step_index = min(step_index + 1, status_steps.size() - 1)
		
	# Check loading status
	var load_status = ResourceLoader.load_threaded_get_status(target_path, progress)
	
	var progress_val = progress[0]
	
	# Update status text and progress bar
	if progress_bar:
		progress_bar.value = progress_val * 100.0
		
	if status_label:
		status_label.text = status_steps[step_index] + " (" + str(round(progress_val * 100.0)) + "%)"
		
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var loaded_res = ResourceLoader.load_threaded_get(target_path)
		get_tree().change_scene_to_packed(loaded_res)
	elif load_status == ResourceLoader.THREAD_LOAD_FAILED or load_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		status_label.text = "Error: Failed to load target scene."
		set_process(false)
