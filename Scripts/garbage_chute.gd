extends InteractableSwitch
@export var open = false
var openTimer = 0

func get_interact_name() -> String:
	return "Hatch"

func _process(delta: float) -> void:
	if (open):
		openTimer += delta
		if (openTimer > 2):
			$"../FlapPivot/AnimationPlayer".play_backwards("open_hatch");
			open = false
			openTimer = 0

func interact(_player):
	if (!open):
		$"../FlapPivot/AnimationPlayer".play("open_hatch")
		open = true
