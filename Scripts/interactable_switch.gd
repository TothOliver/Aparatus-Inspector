extends StaticBody3D
class_name InteractableSwitch

@export var target_node_path: NodePath = ".."
@export var target_method: String = ""
@export var interact_name: String = "Switch"
@export var mesh_on: Node3D = null
@export var mesh_off: Node3D = null
@export var toggle_mesh: Node3D = null

var is_on: bool = true
var _initial_rot: Vector3

func _ready():
	if toggle_mesh:
		_initial_rot = toggle_mesh.rotation
	if target_method == "toggle_door_lock":
		is_on = GameStats.door_locked
	elif target_method == "toggle_ceiling_lights":
		var target = _find_target()
		if target and "is_ceiling_light_on" in target:
			is_on = target.is_ceiling_light_on
	_update_visual_state(false)

func get_interact_name() -> String:
	if target_method == "toggle_door_lock":
		return "Unlock Door" if GameStats.door_locked else "Lock Door"
	return interact_name

func _find_target() -> Node:
	if target_node_path and not target_node_path.is_empty():
		var node = get_node_or_null(target_node_path)
		if node and node.has_method(target_method):
			return node

	var curr = get_parent()
	while curr:
		if curr.has_method(target_method):
			return curr
		curr = curr.get_parent()

	var current_scene = get_tree().current_scene if is_inside_tree() else null
	if current_scene and current_scene.has_method(target_method):
		return current_scene

	if is_inside_tree() and get_tree() and get_tree().root:
		var found = get_tree().root.find_child("Game3D*", true, false)
		if found and found.has_method(target_method):
			return found

	return null

func interact(_player):
	if target_method != "":
		var target: Node = _find_target()
		if target and target.has_method(target_method):
			target.call(target_method)

	is_on = not is_on
	_update_visual_state(true)

func _update_visual_state(animate: bool = true):
	if not toggle_mesh:
		var p = get_parent()
		if p:
			toggle_mesh = p.get_node_or_null("Pivot") as Node3D
			if not toggle_mesh:
				toggle_mesh = p.get_node_or_null("SwitchP2") as Node3D

	if toggle_mesh:
		var p = get_parent()
		if p:
			var p1 = p.get_node_or_null("SwitchP1") as Node3D
			var p2 = p.get_node_or_null("Pivot/SwitchP2") as Node3D
			if not p2:
				p2 = p.get_node_or_null("SwitchP2") as Node3D
			if p1: p1.visible = true
			if p2: p2.visible = true

		var target_deg = 30.0 if is_on else -30.0
		if animate:
			if GameStats.has_method("_play_button_click"):
				GameStats._play_button_click()
			var tween = create_tween()
			tween.tween_property(toggle_mesh, "rotation_degrees:x", target_deg, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		else:
			toggle_mesh.rotation_degrees.x = target_deg
