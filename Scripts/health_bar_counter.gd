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
	if value < 100.0:
		count = max(count, int(round((100.0 - value) / 25.0)))
	text = str(clamp(count, 0, 4)) + " / 4"
