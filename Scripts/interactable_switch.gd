extends StaticBody3D
class_name InteractableSwitch

@export var target_node_path: NodePath = ".."
@export var target_method: String = ""
@export var interact_name: String = "Switch"

func get_interact_name() -> String:
	return interact_name

func interact(_player):
	if target_method != "":
		var target: Node = null
		if target_node_path and not target_node_path.is_empty():
			target = get_node_or_null(target_node_path)
		if not target or not target.has_method(target_method):
			var current_scene = get_tree().current_scene
			if current_scene and current_scene.has_method(target_method):
				target = current_scene
		if not target or not target.has_method(target_method):
			var curr = get_parent()
			while curr:
				if curr.has_method(target_method):
					target = curr
					break
				curr = curr.get_parent()
		if target and target.has_method(target_method):
			target.call(target_method)
