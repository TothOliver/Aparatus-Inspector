extends Node

# ==============================================================================
# SOUND MANAGER - CENTRAL AUDIO REGISTRY & CONTROLLER
# ==============================================================================
# To replace any sound with your own audio file:
# 1. Drop your audio file (.wav, .mp3, or .ogg) into the res://sound/ directory.
# 2. Update the "path" variable in SOUND_CONFIGS below to match your filename.
# 3. Adjust "volume_db" (in decibels, e.g. -6.0 or +3.0) or pitch range per sound.
# ==============================================================================

var SOUND_CONFIGS = {
	# --- NEW REQUESTED SOUND EFFECTS ---
	"power_outage":     { "path": "res://sound/power_outage.wav",     "volume_db": 0.0,   "pitch_min": 0.95, "pitch_max": 1.05 },
	"computer_open":    { "path": "res://sound/computer_open.wav",    "volume_db": -2.0,  "pitch_min": 0.95, "pitch_max": 1.05 },
	"power_restore":   { "path": "res://sound/power_restore.wav",   "volume_db": 0.0,   "pitch_min": 0.95, "pitch_max": 1.05 },
	"monster_footstep": { "path": "res://sound/monster_footstep.wav", "volume_db": +1.0,  "pitch_min": 0.85, "pitch_max": 1.15 },
	"approval":         { "path": "res://sound/approval.wav",         "volume_db": -3.0,  "pitch_min": 0.98, "pitch_max": 1.02 },
	"exterminate":      { "path": "res://sound/exterminate.wav",      "volume_db": 0.0,   "pitch_min": 0.95, "pitch_max": 1.05 },
	"dialogue_typing":  { "path": "res://sound/dialogue_typing.wav",  "volume_db": -12.0, "pitch_min": 0.90, "pitch_max": 1.10 },
	"scribble_typing":  { "path": "res://sound/dialogue_typing.wav",  "volume_db": -10.0, "pitch_min": 1.15, "pitch_max": 1.35 },
	"scan":             { "path": "res://sound/scan.wav",             "volume_db": -4.0,  "pitch_min": 0.95, "pitch_max": 1.05 },
	"player_footstep":  { "path": "res://sound/player_footstep.wav",  "volume_db": -8.0,  "pitch_min": 0.90, "pitch_max": 1.10 },
	"flashlight":       { "path": "res://sound/flashlight.wav",       "volume_db": -5.0,  "pitch_min": 0.95, "pitch_max": 1.05 },
	"hack":             { "path": "res://sound/hack.wav",             "volume_db": -2.0,  "pitch_min": 0.95, "pitch_max": 1.05 },

	# --- PRE-EXISTING PROJECT SOUNDS ---
	"button_click":     { "path": "res://sound/button_click.wav",     "volume_db": -10.0, "pitch_min": 0.95, "pitch_max": 1.05 },
	"victory":          { "path": "res://sound/victory.wav",          "volume_db": 0.0,   "pitch_min": 1.00, "pitch_max": 1.00 },
	"game_over":        { "path": "res://sound/alphix-game-over-417465.mp3", "volume_db": 0.0, "pitch_min": 1.00, "pitch_max": 1.00 },
	"ambient_factory":  { "path": "res://sound/freesound_community-factory-fluorescent-light-buzz-6871.mp3", "volume_db": -10.0, "pitch_min": 1.00, "pitch_max": 1.00 },
	"ambient_horror":   { "path": "res://sound/soundreality-wrong-place-129242.mp3", "volume_db": -6.0, "pitch_min": 1.00, "pitch_max": 1.00 },
	"hunter_screech":   { "path": "res://sound/hunter_screech.wav",   "volume_db": 0.0,   "pitch_min": 0.90, "pitch_max": 1.10 },
	"hunter_rattle":    { "path": "res://sound/hunter_rattle.wav",    "volume_db": 0.0,   "pitch_min": 0.90, "pitch_max": 1.10 },
	"hunter_bush_rustle":{ "path": "res://sound/hunter_bush_rustle.wav","volume_db": 0.0,  "pitch_min": 0.90, "pitch_max": 1.10 },
	"minesweeper_click":{ "path": "res://sound/minesweeper_click.wav","volume_db": -5.0,  "pitch_min": 0.95, "pitch_max": 1.05 },
	"minesweeper_flag": { "path": "res://sound/minesweeper_flag.wav", "volume_db": -5.0,  "pitch_min": 0.95, "pitch_max": 1.05 },
	"minesweeper_explosion":{ "path": "res://sound/minesweeper_explosion.wav","volume_db": 0.0, "pitch_min": 0.90, "pitch_max": 1.10 },
	"minesweeper_win":  { "path": "res://sound/minesweeper_win.wav",  "volume_db": 0.0,   "pitch_min": 1.00, "pitch_max": 1.00 },
	"snake_tick":       { "path": "res://sound/snake_tick.wav",       "volume_db": -12.0, "pitch_min": 0.95, "pitch_max": 1.05 },
	"snake_eat":        { "path": "res://sound/snake_eat.wav",        "volume_db": -4.0,  "pitch_min": 0.95, "pitch_max": 1.05 },
	"snake_die":        { "path": "res://sound/snake_die.wav",        "volume_db": 0.0,   "pitch_min": 0.95, "pitch_max": 1.05 }
}

var _audio_cache: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_preload_audio_files()

func _preload_audio_files():
	for key in SOUND_CONFIGS.keys():
		var config = SOUND_CONFIGS[key]
		var path = config.get("path", "")
		if path != "" and ResourceLoader.exists(path):
			var stream = ResourceLoader.load(path)
			if stream:
				_audio_cache[key] = stream

# ------------------------------------------------------------------------------
# CORE PLAYBACK METHODS
# ------------------------------------------------------------------------------

func play_sound(sound_name: String, extra_volume_db: float = 0.0, override_pitch: float = 0.0, bus_name: String = "SFX") -> Node:
	if not SOUND_CONFIGS.has(sound_name):
		push_warning("SoundManager: Unknown sound key '%s'" % sound_name)
		return null

	var config = SOUND_CONFIGS[sound_name]
	var stream: AudioStream = _get_or_load_stream(sound_name)
	if not stream:
		return null

	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus_name

	var base_vol = config.get("volume_db", 0.0)
	player.volume_db = base_vol + extra_volume_db

	if override_pitch > 0.0:
		player.pitch_scale = override_pitch
	else:
		var p_min = config.get("pitch_min", 1.0)
		var p_max = config.get("pitch_max", 1.0)
		player.pitch_scale = randf_range(p_min, p_max)

	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	return player

func play_sound_3d(sound_name: String, global_pos: Vector3, extra_volume_db: float = 0.0, bus_name: String = "SFX") -> AudioStreamPlayer3D:
	if not SOUND_CONFIGS.has(sound_name):
		push_warning("SoundManager: Unknown sound key '%s'" % sound_name)
		return null

	var config = SOUND_CONFIGS[sound_name]
	var stream: AudioStream = _get_or_load_stream(sound_name)
	if not stream:
		return null

	var player = AudioStreamPlayer3D.new()
	player.stream = stream
	player.bus = bus_name
	player.global_position = global_pos
	player.max_distance = 25.0
	player.unit_size = 3.0

	var base_vol = config.get("volume_db", 0.0)
	player.volume_db = base_vol + extra_volume_db

	var p_min = config.get("pitch_min", 1.0)
	var p_max = config.get("pitch_max", 1.0)
	player.pitch_scale = randf_range(p_min, p_max)

	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(player)
	else:
		add_child(player)

	player.play()
	player.finished.connect(player.queue_free)
	return player

func _get_or_load_stream(sound_name: String) -> AudioStream:
	if _audio_cache.has(sound_name) and _audio_cache[sound_name] != null:
		return _audio_cache[sound_name]

	var config = SOUND_CONFIGS.get(sound_name, {})
	var path = config.get("path", "")
	if path != "" and ResourceLoader.exists(path):
		var loaded = ResourceLoader.load(path)
		if loaded is AudioStream:
			_audio_cache[sound_name] = loaded
			return loaded

	# Fallback to procedural generation if file is missing
	var fallback = _generate_procedural_fallback(sound_name)
	if fallback:
		_audio_cache[sound_name] = fallback
		return fallback

	return null

# ------------------------------------------------------------------------------
# CONVENIENCE API FOR REQUESTED SOUNDS
# ------------------------------------------------------------------------------

func play_power_outage():
	play_sound("power_outage")

func play_computer_open():
	play_sound("computer_open")

func play_power_restore():
	play_sound("power_restore")

func play_monster_footstep(pos_3d = null):
	if pos_3d is Vector3:
		play_sound_3d("monster_footstep", pos_3d)
	else:
		play_sound("monster_footstep")

func play_approval():
	play_sound("approval")

func play_exterminate():
	play_sound("exterminate")

func play_dialogue_typing():
	play_sound("dialogue_typing")

func play_scribble_typing():
	play_sound("scribble_typing")

func play_scan():
	play_sound("scan")

func play_player_footstep():
	play_sound("player_footstep")

func play_flashlight():
	play_sound("flashlight")

func play_hack():
	play_sound("hack")

# ------------------------------------------------------------------------------
# DYNAMIC VOLUME ADJUSTMENT API
# ------------------------------------------------------------------------------

func set_sound_volume(sound_name: String, volume_db: float):
	if SOUND_CONFIGS.has(sound_name):
		SOUND_CONFIGS[sound_name]["volume_db"] = volume_db

func get_sound_volume(sound_name: String) -> float:
	if SOUND_CONFIGS.has(sound_name):
		return SOUND_CONFIGS[sound_name].get("volume_db", 0.0)
	return 0.0

# ------------------------------------------------------------------------------
# PROCEDURAL FALLBACK GENERATOR
# ------------------------------------------------------------------------------

func _generate_procedural_fallback(sound_name: String) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	var num_samples = 800
	var data = PackedByteArray()
	data.resize(num_samples)
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-30.0 * t)
		var freq = 440.0
		if sound_name == "power_outage": freq = max(40.0, 300.0 * (1.0 - t*3.0))
		elif sound_name == "flashlight": freq = 1200.0
		elif sound_name == "monster_footstep": freq = 80.0
		elif sound_name == "dialogue_typing" or sound_name == "scribble_typing": freq = 800.0
		var val = 0.3 if (fmod(t * freq, 1.0) < 0.5) else -0.3
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
	stream.data = data
	return stream
