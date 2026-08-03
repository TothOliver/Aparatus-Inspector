@tool
extends SceneTree

var log_file: FileAccess

func _init():
	log_file = FileAccess.open("res://scratch/dump_output.txt", FileAccess.WRITE)
	log_file.store_line("--- DUMPING MIMIC GLB STRUCTURE ---")
	var glb_path = "res://assets/Mimic/themimicv2byspade1.glb"
	var scene_resource = load(glb_path) as PackedScene
	if not scene_resource:
		log_file.store_line("ERROR: Could not load " + glb_path)
		quit(1)
		return
		
	var instance = scene_resource.instantiate()
	dump_node(instance, 0)
	log_file.close()
	quit(0)

func dump_node(node: Node, indent_level: int):
	var indent = ""
	for i in range(indent_level):
		indent += "  "
	
	log_file.store_line(indent + node.name + " (" + node.get_class() + ")")
	
	if node is Skeleton3D:
		var skel = node as Skeleton3D
		log_file.store_line(indent + "  == BONES COUNT: " + str(skel.get_bone_count()) + " ==")
		for i in range(skel.get_bone_count()):
			var bone_name = skel.get_bone_name(i)
			var parent_idx = skel.get_bone_parent(i)
			var parent_name = skel.get_bone_name(parent_idx) if parent_idx != -1 else "NONE"
			log_file.store_line(indent + "    Bone [" + str(i) + "]: '" + bone_name + "' (Parent: '" + parent_name + "')")
			
	for child in node.get_children():
		dump_node(child, indent_level + 1)
