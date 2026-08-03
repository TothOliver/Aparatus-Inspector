@tool
extends SceneTree

func _init():
	var out_file = FileAccess.open("res://scratch/monster_info.txt", FileAccess.WRITE)
	if not out_file:
		print("Failed to open file")
		quit(1)
		return
	
	out_file.store_line("--- DUMPING MONSTER SCENE ---")
	var scene = load("res://Scenes/MonsterCharacter.tscn") as PackedScene
	if scene:
		var inst = scene.instantiate()
		out_file.store_line("Instantiated root: " + inst.name + " (" + inst.get_class() + ")")
		dump_node(inst, 0, out_file)
	else:
		out_file.store_line("Failed to load res://Scenes/MonsterCharacter.tscn")
	
	out_file.store_line("\n--- DUMPING GLB MODEL DIRECTLY ---")
	var glb = load("res://assets/Mimic/themimicv2byspade1.glb") as PackedScene
	if glb:
		var glb_inst = glb.instantiate()
		out_file.store_line("GLB root: " + glb_inst.name + " (" + glb_inst.get_class() + ")")
		dump_node(glb_inst, 0, out_file)
	else:
		out_file.store_line("Failed to load res://assets/Mimic/themimicv2byspade1.glb")
		
	out_file.close()
	quit(0)

func dump_node(node: Node, depth: int, file: FileAccess):
	var indent = ""
	for i in range(depth):
		indent += "  "
	var extra = ""
	if node is Skeleton3D:
		var skel = node as Skeleton3D
		extra = " [Bones: %d]" % skel.get_bone_count()
		file.store_line(indent + "- " + node.name + " (" + node.get_class() + ")" + extra + " Path: " + str(node.get_path()))
		for b in range(skel.get_bone_count()):
			var b_name = skel.get_bone_name(b)
			var b_parent = skel.get_bone_parent(b)
			var parent_str = skel.get_bone_name(b_parent) if b_parent >= 0 else "ROOT"
			file.store_line(indent + "   Bone #%d: '%s' (parent: '%s')" % [b, b_name, parent_str])
		return
	elif node is AnimationPlayer:
		var anim = node as AnimationPlayer
		var anims = anim.get_animation_list()
		extra = " [Anims: %s]" % str(anims)
		file.store_line(indent + "- " + node.name + " (" + node.get_class() + ")" + extra + " Path: " + str(node.get_path()))
	else:
		file.store_line(indent + "- " + node.name + " (" + node.get_class() + ")" + extra + " Path: " + str(node.get_path()))
	
	for child in node.get_children():
		dump_node(child, depth + 1, file)
