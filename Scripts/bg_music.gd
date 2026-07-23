extends AudioStreamPlayer

func _ready():
	GameStats.ensure_audio_buses()
	bus = &"Music"
	GameStats.apply_bus_volume("Music", GameStats.music_volume)
