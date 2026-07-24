extends Label

var value: float = 100.0:
	set(v):
		value = v
		update_display()

var breaches: int = 0:
	set(b):
		breaches = b
		update_display()

func _ready():
	update_display()

func update_display():
	var count = breaches
	var max_b = GameStats.get_max_allowed_breaches() if GameStats and GameStats.has_method("get_max_allowed_breaches") else 2
	if value < 100.0:
		count = max(count, int(round((100.0 - value) / 50.0)))
	text = str(clamp(count, 0, max_b)) + " / " + str(max_b)
