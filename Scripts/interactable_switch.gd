extends StaticBody3D
class_name InteractableSwitch

@export var target_node_path: NodePath = ".."
@export var target_method: String = ""
@export var interact_name: String = "Switch"

func get_interact_name() -> String:
	return interact_name

func interact(_player):
	if target_method != "":
		var target = get_node_or_null(target_node_path)
		if target and target.has_method(target_method):
			target.call(target_method)
