@tool
extends SceneTree

func _init():
	var file = FileAccess.open("C:/Users/johan/OneDrive/Desktop/awtbg/scratch/skel_info.txt", FileAccess.WRITE)
	if not file:
		print("Failed to open file!")
		quit(1)
		return
	var scene = load("res://Scenes/MonsterCharacter.tscn") as PackedScene
	if scene:
		var inst = scene.instantiate()
		var skel = inst.find_child("*Skeleton3D*", true, false) as Skeleton3D
		if skel:
			file.store_line("Skeleton Node Name: " + skel.name)
			file.store_line("Skeleton Node Path from MonsterCharacter: " + str(inst.get_path_to(skel)))
			file.store_line("Bone Count: " + str(skel.get_bone_count()))
			file.store_line("\n--- Key Bones Found ---")
			var key_words = ["head", "spine", "arm", "hand", "leg", "foot", "collar"]
			for i in range(skel.get_bone_count()):
				var bname = skel.get_bone_name(i)
				for kw in key_words:
					if kw in bname.lower():
						file.store_line("Bone [" + str(i) + "]: " + bname)
						break
		else:
			file.store_line("No Skeleton3D found!")
	else:
		file.store_line("Failed to load scene!")
	file.close()
	quit(0)
