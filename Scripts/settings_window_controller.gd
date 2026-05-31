extends Control

@onready var crt_checkbox = $CRTCheckbox
@onready var volume_slider = $VolumeSlider
@onready var volume_value_label = $VolumeValueLabel
@onready var sensitivity_slider = $SensitivitySlider
@onready var sensitivity_value_label = $SensitivityValueLabel
@onready var quit_button = $QuitButton

func _ready():
	visibility_changed.connect(update_ui_from_stats)
	update_ui_from_stats()
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func update_ui_from_stats():
	if crt_checkbox:
		if crt_checkbox.toggled.is_connected(_on_crt_toggled):
			crt_checkbox.toggled.disconnect(_on_crt_toggled)
		crt_checkbox.button_pressed = GameStats.crt_effect_enabled
		crt_checkbox.toggled.connect(_on_crt_toggled)
		_on_crt_toggled(GameStats.crt_effect_enabled)

	if volume_slider:
		if volume_slider.value_changed.is_connected(_on_volume_changed):
			volume_slider.value_changed.disconnect(_on_volume_changed)
		volume_slider.value = GameStats.master_volume
		volume_slider.value_changed.connect(_on_volume_changed)
		_on_volume_changed(GameStats.master_volume)

	if sensitivity_slider:
		if sensitivity_slider.value_changed.is_connected(_on_sensitivity_changed):
			sensitivity_slider.value_changed.disconnect(_on_sensitivity_changed)
		var t = (GameStats.mouse_sensitivity - 0.02) / (0.5 - 0.02)
		sensitivity_slider.value = clamp(t * 100.0, 0.0, 100.0)
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
		_on_sensitivity_changed(sensitivity_slider.value)

func _on_crt_toggled(toggled_on: bool):
	GameStats.crt_effect_enabled = toggled_on
	var crt_overlay = get_tree().root.find_child("CRTOverlay", true, false)
	if crt_overlay:
		crt_overlay.visible = toggled_on

func _on_volume_changed(value: float):
	GameStats.master_volume = value
	if volume_value_label:
		volume_value_label.text = str(round(value)) + "%"
	
	var bus_idx = AudioServer.get_bus_index("Master")
	if value <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		# Convert 0..100 linear value to decibels (-40 dB to 0 dB range)
		var db = -40.0 * (1.0 - (value / 100.0))
		if value <= 5.0:
			db = -80.0
		AudioServer.set_bus_volume_db(bus_idx, db)

func _on_sensitivity_changed(value: float):
	# Map slider 0..100 to sensitivity range 0.02 to 0.5
	var sens = 0.02 + (value / 100.0) * (0.5 - 0.02)
	GameStats.mouse_sensitivity = sens
	if sensitivity_value_label:
		sensitivity_value_label.text = "%.2f" % sens

func _on_quit_pressed():
	get_tree().quit()
