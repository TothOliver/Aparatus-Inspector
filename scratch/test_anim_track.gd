@tool
extends SceneTree

func _init():
	var out_file = FileAccess.open("res://scratch/anim_test_result.txt", FileAccess.WRITE)
	if not out_file:
		quit(1)
		return
	
	var scene = load("res://Scenes/MonsterCharacter.tscn") as PackedScene
	if not scene:
		out_file.store_line("Failed to load scene")
		out_file.close()
		quit(1)
		return
		
	var inst = scene.instantiate()
	var skel_path = "themimicv2byspade1/Sketchfab_model/root/GLTF_SceneRootNode/Sketchfab_model_0/root_1/GLTF_SceneRootNode_2/The Mimic_566_5/GLTF_created_0_6/GLTF_created_0/Skeleton3D"
	var skel = inst.get_node_or_null(skel_path) as Skeleton3D
	
	if not skel:
		out_file.store_line("Skeleton not found at " + skel_path)
		out_file.close()
		quit(1)
		return
		
	out_file.store_line("Skeleton found! Bone count: %d" % skel.get_bone_count())
	var bone_idx = skel.find_bone("arm_l0_205_412")
	out_file.store_line("Bone 'arm_l0_205_412' index: %d" % bone_idx)
	if bone_idx >= 0:
		var orig_pose = skel.get_bone_pose_rotation(bone_idx)
		out_file.store_line("Original bone pose rotation: " + str(orig_pose))
		
		# Create an AnimationPlayer dynamically and test playing a rotation track
		var anim_player = AnimationPlayer.new()
		anim_player.name = "AnimationPlayer"
		inst.add_child(anim_player)
		
		var anim_lib = AnimationLibrary.new()
		var anim = Animation.new()
		var track_idx = anim.add_track(Animation.TYPE_ROTATION_3D)
		
		var target_track_path = NodePath(skel_path + ":arm_l0_205_412")
		anim.track_set_path(track_idx, target_track_path)
		
		# Rotate arm 45 deg around Z axis
		var target_quat = Quaternion(Vector3(0, 0, 1), deg_to_rad(45.0))
		anim.track_insert_key(track_idx, 0.0, target_quat)
		
		anim_lib.add_animation("TestPose", anim)
		anim_player.add_animation_library("", anim_lib)
		
		anim_player.play("TestPose")
		anim_player.advance(0.0)
		
		var new_pose = skel.get_bone_pose_rotation(bone_idx)
		out_file.store_line("New bone pose rotation after playing anim: " + str(new_pose))
		out_file.store_line("Did rotation change? " + str(orig_pose != new_pose))
		
	out_file.close()
	quit(0)
