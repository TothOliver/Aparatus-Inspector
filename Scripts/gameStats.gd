extends Node

var final_missed_score: int = 0
var total_security_breaches: int = 0
var innocent_robots_killed: int = 0
var good_robots_through: int = 0
var bad_robots_terminated: int = 0
var let_through_bad_sprites: Array = []

# Gameplay depth additions
enum DifficultyMode { NORMAL, HARD, NIGHTMARE }
var difficulty_mode: DifficultyMode = DifficultyMode.NORMAL

func get_max_allowed_breaches() -> int:
	if difficulty_mode == DifficultyMode.NIGHTMARE:
		return 1
	return 2

func is_permadeath() -> bool:
	return difficulty_mode == DifficultyMode.HARD or difficulty_mode == DifficultyMode.NIGHTMARE

var current_day: int = 1
var power_level: float = 100.0
var cctv_light_on: bool = false
var door_locked: bool = false
var hack_active: bool = false
var hack_progress: float = 0.0
var is_victory: bool = false
var casino_balance: float = 100.0
var wifi_on: bool = true
var player_health: float = 100.0

var read_emails: Dictionary = {1: false, 2: false, 3: false}

# User System Settings
var mouse_sensitivity: float = 0.15
var invert_mouse_x: bool = false
var invert_mouse_y: bool = false
var fov: float = 70.0
var crt_effect_enabled: bool = true
var brightness: float = 100.0
var master_volume: float = 80.0
var music_volume: float = 80.0
var sfx_volume: float = 80.0
var ambient_volume: float = 80.0
var audio_output_device: String = "Default"
var fullscreen_enabled: bool = true
var display_mode: int = 2 # 0 = Windowed, 1 = Borderless, 2 = Fullscreen
var vsync_enabled: bool = true
var fps_limit: int = 0 # 0 = Unlimited
var resolution_width: int = 1920
var resolution_height: int = 1080

const SAVE_PATH = "user://settings.cfg"
const SAVE_GAME_PATH = "user://savegame.cfg"

const DEFAULT_BINDS = {
	"move_forward": KEY_W,
	"move_backward": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"crouch": KEY_CTRL,
	"interact": KEY_E,
	"toggle_flashlight": KEY_F
}

var custom_keybinds: Dictionary = {}

signal fullscreen_toggled(is_fullscreen: bool)
signal fov_changed(new_fov: float)

var target_scene_path: String = ""

var button_click_player: AudioStreamPlayer
var button_click_stream: AudioStreamWAV

func ensure_audio_buses():
	var buses = ["Music", "SFX", "Ambient"]
	for bus in buses:
		if AudioServer.get_bus_index(bus) == -1:
			var idx = AudioServer.bus_count
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bus)
			AudioServer.set_bus_send(idx, "Master")

func save_settings():
	var config = ConfigFile.new()
	config.set_value("Settings", "primary_monitor_initialized", true)
	config.set_value("Settings", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("Settings", "invert_mouse_x", invert_mouse_x)
	config.set_value("Settings", "invert_mouse_y", invert_mouse_y)
	config.set_value("Settings", "fov", fov)
	config.set_value("Settings", "crt_effect_enabled", crt_effect_enabled)
	config.set_value("Settings", "brightness", brightness)
	config.set_value("Settings", "master_volume", master_volume)
	config.set_value("Settings", "music_volume", music_volume)
	config.set_value("Settings", "sfx_volume", sfx_volume)
	config.set_value("Settings", "ambient_volume", ambient_volume)
	config.set_value("Settings", "audio_output_device", audio_output_device)
	config.set_value("Settings", "fullscreen_enabled", fullscreen_enabled)
	config.set_value("Settings", "display_mode", display_mode)
	config.set_value("Settings", "vsync_enabled", vsync_enabled)
	config.set_value("Settings", "fps_limit", fps_limit)
	config.set_value("Settings", "resolution_width", resolution_width)
	config.set_value("Settings", "resolution_height", resolution_height)
	
	for action in custom_keybinds.keys():
		config.set_value("Keybinds", action, custom_keybinds[action])
		
	var err = config.save(SAVE_PATH)
	if err != OK:
		print("Error saving settings: ", err)

func get_primary_monitor_resolution() -> Vector2i:
	var primary_screen = DisplayServer.get_primary_screen()
	var size = DisplayServer.screen_get_size(primary_screen)
	if size.x > 0 and size.y > 0:
		return size
	return Vector2i(1920, 1080)

func get_primary_monitor_refresh_rate() -> int:
	var primary_screen = DisplayServer.get_primary_screen()
	var rate = DisplayServer.screen_get_refresh_rate(primary_screen)
	if rate > 0.0:
		return int(round(rate))
	return 60

func load_settings():
	ensure_audio_buses()
	var primary_res = get_primary_monitor_resolution()
	var primary_refresh = get_primary_monitor_refresh_rate()
	
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	var is_first_run = not config.get_value("Settings", "primary_monitor_initialized", false)
	
	if err == OK and not is_first_run:
		mouse_sensitivity = config.get_value("Settings", "mouse_sensitivity", mouse_sensitivity)
		invert_mouse_x = config.get_value("Settings", "invert_mouse_x", invert_mouse_x)
		invert_mouse_y = config.get_value("Settings", "invert_mouse_y", invert_mouse_y)
		fov = config.get_value("Settings", "fov", fov)
		crt_effect_enabled = config.get_value("Settings", "crt_effect_enabled", crt_effect_enabled)
		brightness = config.get_value("Settings", "brightness", brightness)
		master_volume = config.get_value("Settings", "master_volume", master_volume)
		music_volume = config.get_value("Settings", "music_volume", music_volume)
		sfx_volume = config.get_value("Settings", "sfx_volume", config.get_value("Settings", "vfx_volume", sfx_volume))
		ambient_volume = config.get_value("Settings", "ambient_volume", ambient_volume)
		audio_output_device = config.get_value("Settings", "audio_output_device", audio_output_device)
		fullscreen_enabled = config.get_value("Settings", "fullscreen_enabled", fullscreen_enabled)
		display_mode = config.get_value("Settings", "display_mode", 2 if fullscreen_enabled else 0)
		vsync_enabled = config.get_value("Settings", "vsync_enabled", vsync_enabled)
		fps_limit = config.get_value("Settings", "fps_limit", primary_refresh)
		resolution_width = config.get_value("Settings", "resolution_width", primary_res.x)
		resolution_height = config.get_value("Settings", "resolution_height", primary_res.y)
		
		if config.has_section("Keybinds"):
			for action in config.get_section_keys("Keybinds"):
				custom_keybinds[action] = config.get_value("Keybinds", action)
	else:
		if err == OK:
			mouse_sensitivity = config.get_value("Settings", "mouse_sensitivity", mouse_sensitivity)
			invert_mouse_x = config.get_value("Settings", "invert_mouse_x", invert_mouse_x)
			invert_mouse_y = config.get_value("Settings", "invert_mouse_y", invert_mouse_y)
			fov = config.get_value("Settings", "fov", fov)
			crt_effect_enabled = config.get_value("Settings", "crt_effect_enabled", crt_effect_enabled)
			brightness = config.get_value("Settings", "brightness", brightness)
			master_volume = config.get_value("Settings", "master_volume", master_volume)
			music_volume = config.get_value("Settings", "music_volume", music_volume)
			sfx_volume = config.get_value("Settings", "sfx_volume", config.get_value("Settings", "vfx_volume", sfx_volume))
			ambient_volume = config.get_value("Settings", "ambient_volume", ambient_volume)
			fullscreen_enabled = config.get_value("Settings", "fullscreen_enabled", fullscreen_enabled)
			display_mode = config.get_value("Settings", "display_mode", 2 if fullscreen_enabled else 0)
			vsync_enabled = config.get_value("Settings", "vsync_enabled", vsync_enabled)
			if config.has_section("Keybinds"):
				for action in config.get_section_keys("Keybinds"):
					custom_keybinds[action] = config.get_value("Keybinds", action)

		resolution_width = primary_res.x
		resolution_height = primary_res.y
		fps_limit = primary_refresh
		save_settings()
	
	apply_all_settings()

func apply_all_settings():
	# Display mode & resolution
	if display_mode == 0: # Windowed
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(resolution_width, resolution_height))
		var screen_size = DisplayServer.screen_get_size()
		var pos = Vector2i((Vector2(screen_size - Vector2i(resolution_width, resolution_height)) / 2.0).round())
		DisplayServer.window_set_position(pos)
		fullscreen_enabled = false
	elif display_mode == 1: # Borderless
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_enabled = true
	else: # Fullscreen (Exclusive)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		fullscreen_enabled = true

	# VSync
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# FPS Limit
	Engine.max_fps = fps_limit

	# Audio Volumes & Output
	apply_audio_output_device()
	apply_bus_volume("Master", master_volume)
	apply_bus_volume("Music", music_volume)
	apply_bus_volume("SFX", sfx_volume)
	apply_bus_volume("Ambient", ambient_volume)

func apply_audio_output_device():
	var devices = AudioServer.get_output_device_list()
	if audio_output_device in devices:
		AudioServer.output_device = audio_output_device
	else:
		AudioServer.output_device = "Default"
		
	setup_input_map()
	apply_brightness()
	apply_fov()

func apply_fov():
	fov_changed.emit(fov)
	if is_inside_tree() and get_tree() and get_tree().root:
		var player = get_tree().root.find_child("Player", true, false)
		if player and player.get_node_or_null("Camera3D"):
			var cam = player.get_node_or_null("Camera3D")
			if cam is Camera3D:
				cam.fov = fov
		else:
			var cam = get_tree().root.find_child("Camera3D", true, false)
			if cam is Camera3D and cam.name == "Camera3D" and cam.get_parent() and cam.get_parent().name == "Player":
				cam.fov = fov

func apply_brightness():
	update_crt_overlays()
	if is_inside_tree() and get_tree() and get_tree().root:
		var env_node = get_tree().root.find_child("WorldEnvironment", true, false)
		if env_node and env_node is WorldEnvironment and env_node.environment:
			env_node.environment.adjustment_enabled = true
			env_node.environment.adjustment_brightness = brightness / 100.0

func apply_bus_volume(bus_name: String, value: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return
	if value <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		var db = -40.0 * (1.0 - (value / 100.0))
		if value <= 5.0:
			db = -80.0
		AudioServer.set_bus_volume_db(bus_idx, db)

func setup_input_map():
	for action in DEFAULT_BINDS.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		else:
			InputMap.action_erase_events(action)
			
		var keycode = DEFAULT_BINDS[action]
		if action in custom_keybinds:
			keycode = custom_keybinds[action]
			
		var event = InputEventKey.new()
		event.keycode = keycode
		InputMap.action_add_event(action, event)
		
		# Add default alternative keys (Arrow keys for WASD movement) if not rebound
		if not (action in custom_keybinds):
			if action == "move_forward":
				var alt = InputEventKey.new()
				alt.keycode = KEY_UP
				InputMap.action_add_event(action, alt)
			elif action == "move_backward":
				var alt = InputEventKey.new()
				alt.keycode = KEY_DOWN
				InputMap.action_add_event(action, alt)
			elif action == "move_left":
				var alt = InputEventKey.new()
				alt.keycode = KEY_LEFT
				InputMap.action_add_event(action, alt)
			elif action == "move_right":
				var alt = InputEventKey.new()
				alt.keycode = KEY_RIGHT
				InputMap.action_add_event(action, alt)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	button_click_player = AudioStreamPlayer.new()
	button_click_player.volume_db = -10.0
	button_click_player.bus = "SFX"
	add_child(button_click_player)
	
	button_click_stream = _generate_button_click_sound()
	
	load_settings()
	
	# Listen to new nodes added to the tree dynamically
	get_tree().node_added.connect(_on_node_added)
	
	# Recursively connect to all buttons currently in the tree
	_connect_buttons_recursive(get_tree().root)
	
	# Connect Steam overlay signals
	if Engine.has_singleton("Steam"):
		var steam = Engine.get_singleton("Steam")
		steam.overlay_toggled.connect(_on_overlay_toggled)

func _on_node_added(node: Node):
	if node is Button:
		_connect_button(node)
	if node is CanvasItem and (node.name == "CRTOverlay" or node.name == "PauseCRTOverlay" or node.is_in_group("CRTOverlays")):
		if not node.is_in_group("CRTOverlays"):
			node.add_to_group("CRTOverlays")
		apply_brightness()

func update_crt_overlays():
	if not is_inside_tree():
		return
	var factor = brightness / 100.0
	for crt in get_tree().get_nodes_in_group("CRTOverlays"):
		if crt is CanvasItem:
			if crt_effect_enabled:
				crt.visible = true
				if crt.material and crt.material is ShaderMaterial:
					crt.material.set_shader_parameter("scanline_intensity", 0.08)
					crt.material.set_shader_parameter("vignette_intensity", 0.08)
					crt.material.set_shader_parameter("brightness", factor)
			else:
				if abs(brightness - 100.0) < 0.1:
					crt.visible = false
				else:
					crt.visible = true
					if crt.material and crt.material is ShaderMaterial:
						crt.material.set_shader_parameter("scanline_intensity", 0.0)
						crt.material.set_shader_parameter("vignette_intensity", 0.0)
						crt.material.set_shader_parameter("brightness", factor)

func _connect_buttons_recursive(node: Node):
	if node is Button:
		_connect_button(node)
	for child in node.get_children():
		_connect_buttons_recursive(child)

func _connect_button(btn: Button):
	if not btn.pressed.is_connected(_play_button_click):
		btn.pressed.connect(_play_button_click)

func _play_button_click():
	if button_click_player and button_click_stream:
		button_click_player.pitch_scale = randf_range(0.95, 1.05)
		button_click_player.stream = button_click_stream
		button_click_player.play()

func _generate_button_click_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 300 # ~0.027s
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-250.0 * t)
		# 600Hz clean blip
		var val = 0.25 if (fmod(t * 600.0, 1.0) < 0.5) else -0.25
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream

func generate_victory_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	
	var notes = [
		{"freq": 523.25, "duration": 0.10}, # C5
		{"freq": 659.25, "duration": 0.10}, # E5
		{"freq": 783.99, "duration": 0.10}, # G5
		{"freq": 1046.50, "duration": 0.15}, # C6
		{"freq": 1318.51, "duration": 0.45}  # E6 (celebratory flourish)
	]
	
	var total_duration = 0.0
	for note in notes:
		total_duration += note.duration
		
	var num_samples = int(total_duration * 22050.0)
	var data = PackedByteArray()
	data.resize(num_samples)
	
	var sample_idx = 0
	for note in notes:
		var note_samples = int(note.duration * 22050.0)
		for i in range(note_samples):
			var t = float(i) / 22050.0
			var envelope = 1.0 - (float(i) / float(note_samples)) * 0.6
			var wave1 = 0.35 if (fmod(t * note.freq, 1.0) < 0.5) else -0.35
			var wave2 = 0.15 if (fmod(t * (note.freq * 2.0), 1.0) < 0.5) else -0.15
			var val = (wave1 + wave2) * envelope
			data[sample_idx] = int(clamp((val * 127.0) + 128.0, 0, 255))
			sample_idx += 1
			
	stream.data = data
	return stream

func play_victory_sound():
	var player = AudioStreamPlayer.new()
	player.stream = generate_victory_sound()
	player.bus = "SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func save_game():
	var config = ConfigFile.new()
	config.set_value("Game", "current_day", current_day)
	config.set_value("Game", "difficulty_mode", int(difficulty_mode))
	config.set_value("Game", "casino_balance", casino_balance)
	config.set_value("Game", "player_health", player_health)
	config.set_value("Game", "total_security_breaches", total_security_breaches)
	config.set_value("Game", "innocent_robots_killed", innocent_robots_killed)
	config.set_value("Game", "good_robots_through", good_robots_through)
	config.set_value("Game", "bad_robots_terminated", bad_robots_terminated)
	config.set_value("Game", "final_missed_score", final_missed_score)
	
	for day in read_emails.keys():
		config.set_value("Emails", str(day), read_emails[day])
		
	var err = config.save(SAVE_GAME_PATH)
	if err != OK:
		print("Error saving game: ", err)
	else:
		print("Game autosaved successfully for Day ", current_day)

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)

func load_game() -> bool:
	if not has_save_file():
		return false
	var config = ConfigFile.new()
	var err = config.load(SAVE_GAME_PATH)
	if err != OK:
		print("Error loading save game: ", err)
		return false
		
	difficulty_mode = config.get_value("Game", "difficulty_mode", DifficultyMode.NORMAL) as DifficultyMode
	current_day = config.get_value("Game", "current_day", 1)
	casino_balance = config.get_value("Game", "casino_balance", 100.0)
	player_health = config.get_value("Game", "player_health", 100.0)
	total_security_breaches = config.get_value("Game", "total_security_breaches", 0)
	innocent_robots_killed = config.get_value("Game", "innocent_robots_killed", 0)
	good_robots_through = config.get_value("Game", "good_robots_through", 0)
	bad_robots_terminated = config.get_value("Game", "bad_robots_terminated", 0)
	final_missed_score = config.get_value("Game", "final_missed_score", 0)
	
	if config.has_section("Emails"):
		for day_str in config.get_section_keys("Emails"):
			var d = int(day_str)
			read_emails[d] = config.get_value("Emails", day_str, false)
			
	# Reset transient per-day state
	power_level = 100.0
	door_locked = false
	hack_active = false
	hack_progress = 0.0
	wifi_on = true
	let_through_bad_sprites.clear()
	
	print("Game loaded successfully. Resuming Day ", current_day)
	return true

func delete_save_game():
	if has_save_file():
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("savegame.cfg")
			print("Save game deleted.")

func reset_fail_quota() -> void:
	total_security_breaches = 0
	player_health = 100.0
	let_through_bad_sprites.clear()

func reset_game_state():
	final_missed_score = 0
	total_security_breaches = 0
	innocent_robots_killed = 0
	good_robots_through = 0
	bad_robots_terminated = 0
	let_through_bad_sprites.clear()
	
	current_day = 1
	power_level = 100.0
	door_locked = false
	hack_active = false
	hack_progress = 0.0
	is_victory = false
	casino_balance = 100.0
	wifi_on = true
	player_health = 100.0
	read_emails = {1: false, 2: false, 3: false}

func quit_or_menu(tree: SceneTree):
	if tree.current_scene and (tree.current_scene.scene_file_path == "res://Scenes/MainMenu.tscn" or tree.current_scene.name == "MainMenu"):
		tree.quit()
	else:
		tree.paused = false
		tree.change_scene_to_file.call_deferred("res://Scenes/MainMenu.tscn")

func change_scene_with_loading(tree: SceneTree, target_path: String):
	target_scene_path = target_path
	tree.paused = false
	tree.change_scene_to_file.call_deferred("res://Scenes/LoadingScreen.tscn")

func _input(event):
	if not is_inside_tree():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var is_f11 = event.keycode == KEY_F11
		var is_enter = event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER
		var is_alt_enter = is_enter and event.alt_pressed
		if is_f11 or is_alt_enter:
			get_viewport().set_input_as_handled()
			var mode = DisplayServer.window_get_mode()
			if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				fullscreen_enabled = false
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				fullscreen_enabled = true
			fullscreen_toggled.emit(fullscreen_enabled)

func has_unread_mail() -> bool:
	for d in range(1, current_day):
		read_emails[d] = true
	if current_day in read_emails and not read_emails[current_day]:
		return true
	return false

func _process(_delta: float) -> void:
	if Engine.has_singleton("Steam"):
		Engine.get_singleton("Steam").run_callbacks()

func _on_overlay_toggled(active: bool) -> void:
	if active:
		get_tree().paused = true
	else:
		# Only unpause if the in-game pause menu isn't open
		var current_scene = get_tree().current_scene
		var is_pause_menu_open = false
		if current_scene:
			var pause_menu = current_scene.get_node_or_null("HUD/PauseMenu")
			if pause_menu and pause_menu.visible:
				is_pause_menu_open = true
		
		if not is_pause_menu_open:
			get_tree().paused = false
