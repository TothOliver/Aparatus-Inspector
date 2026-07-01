extends CharacterBody3D
class_name HunterBase

@export_group("Modular Markers")
@export var start_marker: Marker3D      # Far corridor starting/idle point
@export var door_marker: Marker3D       # Point directly outside the office door
@export var window_marker: Node3D       # The glass window node (used for sight check)
@export var window_peek_marker: Marker3D # Where the Hunter stands to peek through the window
@export var camera_peek_marker: Marker3D # Where the Hunter stands to be seen by the CCTV camera
@export var jumpscare_marker: Marker3D  # Where the Hunter warps to jumpscare the player

@export_group("Modular Mesh & Audio overrides")
@export var door_mesh_override: Node3D  # The door mesh to swing open
@export var custom_audio_player: AudioStreamPlayer3D # Audio override (defaults to child)

@onready var audio_player = $AudioStreamPlayer3D
@onready var door_mesh = $"../Office/LeftDoor" # Default scene fallback

# --- BACKWARD COMPATIBILITY FALLBACKS ---
var start_x: float = -15.0
var door_x: float = -3.1
var target_z: float = 1.5

# Sit/stand location of player inside office
var player_office_pos: Vector3 = Vector3(0.0, 1.0, 0.5)

# Procedural audio assets
var step_stream: AudioStreamWAV
var screech_stream: AudioStreamWAV
var rattle_stream: AudioStreamWAV
var concrete_step_stream: AudioStreamWAV
var bush_rustle_stream: AudioStreamWAV

# Logic timers
var is_active: bool = false

# --- POSITION & REFERENCE GETTERS (Resolves overrides vs fallbacks) ---
func get_start_pos() -> Vector3:
	if start_marker:
		return start_marker.global_position
	return Vector3(start_x, 1.0, target_z)

func get_door_pos() -> Vector3:
	if door_marker:
		return door_marker.global_position
	return Vector3(door_x, 1.0, target_z)

func get_window_pos() -> Vector3:
	if window_marker:
		return window_marker.global_position
	return Vector3(0.0, 1.3, -1.54)

func get_jumpscare_pos() -> Vector3:
	if jumpscare_marker:
		return jumpscare_marker.global_position
	return get_door_pos()

func get_door_mesh() -> Node3D:
	if door_mesh_override:
		return door_mesh_override
	return door_mesh

func get_active_audio_player() -> AudioStreamPlayer3D:
	if custom_audio_player:
		return custom_audio_player
	return audio_player

func _ready():
	# Generate procedural sounds
	step_stream = _generate_clank_sound()
	screech_stream = _generate_screech_sound()
	rattle_stream = _generate_rattle_sound()
	concrete_step_stream = _generate_concrete_step_sound()
	bush_rustle_stream = _generate_bush_rustle_sound()
	
	audio_player.unit_size = 4.0
	audio_player.max_db = 3.0

# === PROCEDURAL AUDIO GENERATION ===

func _generate_clank_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 3000 # ~0.27s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-22.0 * t)
		var val = sin(2.0 * PI * 75.0 * t) * 0.45 + sin(2.0 * PI * 210.0 * t) * 0.3 + (randf() - 0.5) * 0.18
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream

func _generate_screech_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 12000 # ~1.1s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var freq = 600.0 + sin(2.0 * PI * 8.0 * t) * 250.0
		var val = sin(2.0 * PI * freq * t) * 0.7 + (randf() - 0.5) * 0.25
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream

func _generate_rattle_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 8000 # ~0.72s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var rattle_env = abs(sin(2.0 * PI * 18.0 * t))
		var env = exp(-35.0 * fmod(t, 0.05)) * rattle_env
		var val = (randf() - 0.5) * 0.8
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream

func _generate_concrete_step_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 6000 # ~0.54s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		var env = exp(-12.0 * t)
		# Low heavy thud + concrete friction noise
		var low_thud = sin(2.0 * PI * 55.0 * t) * 0.6
		var grit = (randf() - 0.5) * 0.25 * exp(-30.0 * t) # short crunch
		var val = low_thud + grit
		data[i] = int(clamp((val * env) * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream

func _generate_bush_rustle_sound() -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	
	var num_samples = 8000 # ~0.72s
	var data = PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t = float(i) / 11025.0
		# Create multiple distinct bursts of rustling
		var burst_env = exp(-20.0 * fmod(t, 0.2)) if t < 0.6 else 0.0
		var val = (randf() - 0.5) * 0.7 * burst_env
		data[i] = int(clamp(val * 127.0 + 128.0, 0, 255))
		
	stream.data = data
	return stream
