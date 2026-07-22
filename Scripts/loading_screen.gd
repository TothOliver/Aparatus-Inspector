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
var displayed_progress: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if progress_bar:
		progress_bar.show_percentage = true
		progress_bar.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		progress_bar.value = 0.0
	
	if crt_overlay:
		crt_overlay.add_to_group("CRTOverlays")
		crt_overlay.visible = GameStats.crt_effect_enabled
		
	target_path = GameStats.target_scene_path
	if target_path.is_empty():
		target_path = "res://Scenes/MainMenu.tscn" # Fallback
		
	# Start background loading request if not already in progress or loaded
	var current_status = ResourceLoader.load_threaded_get_status(target_path)
	if current_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		var err = ResourceLoader.load_threaded_request(target_path)
		if err != OK and err != ERR_ALREADY_IN_USE:
			if status_label:
				status_label.text = "Error: Failed to request scene load."
			set_process(false)

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# Check actual background loading status
	var load_status = ResourceLoader.load_threaded_get_status(target_path, progress)
	var real_progress = progress[0] if progress.size() > 0 else 0.0
	
	# If scene is ready (e.g. preloaded from Main Menu or finished loading thread)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		if progress_bar:
			progress_bar.value = 100.0
		if status_label:
			status_label.text = status_steps[-1] + " (100.0%)"
		var loaded_res = ResourceLoader.load_threaded_get(target_path)
		get_tree().change_scene_to_packed.call_deferred(loaded_res)
		set_process(false)
		return
	elif load_status == ResourceLoader.THREAD_LOAD_FAILED or load_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		if status_label:
			status_label.text = "Error: Failed to load target scene."
		set_process(false)
		return

	# Smooth progression while loading
	var time_progress = clamp(elapsed_time / min_load_time, 0.0, 1.0)
	var target_progress = min(0.95, max(real_progress, time_progress * 0.95))
	displayed_progress = move_toward(displayed_progress, target_progress, delta * 2.0)
	
	if progress_bar:
		progress_bar.value = displayed_progress * 100.0
		
	if status_label:
		step_index = clamp(int(displayed_progress * status_steps.size()), 0, status_steps.size() - 1)
		var pct_str = "%.1f" % (displayed_progress * 100.0)
		status_label.text = status_steps[step_index] + " (" + pct_str + "%)"
