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
var elapsed_time: float = 0.0
var min_load_time: float = 0.5

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
	elapsed_time += delta
	
	# Determine step index based on elapsed time dynamically spread over minimum duration
	step_index = clamp(int(elapsed_time / (min_load_time / float(status_steps.size()))), 0, status_steps.size() - 1)
		
	# Check actual background loading status
	var load_status = ResourceLoader.load_threaded_get_status(target_path, progress)
	var progress_val = progress[0]
	
	# Visual progress is elapsed time ratio
	var visual_progress = clamp(elapsed_time / min_load_time, 0.0, 1.0)
	
	# Display progress is the minimum of visual progress and actual loader progress
	var display_progress = min(progress_val, visual_progress)
	
	# Update status text and progress bar
	if progress_bar:
		progress_bar.value = display_progress * 100.0
		
	if status_label:
		status_label.text = status_steps[step_index] + " (" + str(round(display_progress * 100.0)) + "%)"
		
	# Only transition once the loading is complete AND the minimum time has elapsed
	if load_status == ResourceLoader.THREAD_LOAD_LOADED and elapsed_time >= min_load_time:
		var loaded_res = ResourceLoader.load_threaded_get(target_path)
		get_tree().change_scene_to_packed.call_deferred(loaded_res)
	elif load_status == ResourceLoader.THREAD_LOAD_FAILED or load_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		status_label.text = "Error: Failed to load target scene."
		set_process(false)
