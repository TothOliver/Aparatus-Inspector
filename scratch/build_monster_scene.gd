@tool
extends SceneTree

const SKEL_PATH = "themimicv2byspade1/Sketchfab_model/root/GLTF_SceneRootNode/Sketchfab_model_0/root_1/GLTF_SceneRootNode_2/The Mimic_566_5/GLTF_created_0_6/GLTF_created_0/Skeleton3D"

# Bone mapping table
const BONES = {
	"head": "head_68_244",
	"neck": "neck_0_72_237",
	"chest": "spine_2_396_59",
	"spine_mid": "spine_1_398_56",
	"spine_low": "spine_0_400_52",
	"pelvis": "Bone_502_12",
	"collar_l": "collar_l_213_393",
	"arm_l0": "arm_l0_205_412",
	"arm_l1": "arm_l1_190_444",
	"hand_l": "hand_l_178_467",
	"collar_r": "collar_r_325_654",
	"arm_r0": "arm_r0_317_673",
	"arm_r1": "arm_r1_302_704",
	"hand_r": "hand_r_290_727",
	"leg_l0": "leg_l0_extend_432_918",
	"leg_l1": "leg_l1_424_931",
	"foot_l": "foot_l0_529_1052",
	"leg_r0": "leg_r0_extend_462_987",
	"leg_r1": "leg_r1_extend_end_439_1032",
	"foot_r": "foot_r0_560_1111",
	"jaw": "jaw_10_308"
}

func _init():
	print("Building MonsterCharacter scene...")
	var root = CharacterBody3D.new()
	root.name = "MonsterCharacter"
	root.transform.origin = Vector3(0, -0.08938873, 0)
	
	var script = load("res://Scripts/monster_character.gd")
	if script:
		root.set_script(script)
		
	# CollisionShape3D
	var col = CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var shape = SphereShape3D.new()
	col.shape = shape
	root.add_child(col)
	col.owner = root
	
	# Instantiate GLB
	var glb_scene = load("res://assets/Mimic/themimicv2byspade1.glb") as PackedScene
	if not glb_scene:
		print("ERROR: Failed to load GLB model")
		quit(1)
		return
		
	var mimic = glb_scene.instantiate()
	mimic.name = "themimicv2byspade1"
	mimic.transform = Transform3D(Vector3(-0.1, 0, 0), Vector3(0, 0.1, 0), Vector3(0, 0, -0.1), Vector3(0, 1.6655425, 0))
	root.add_child(mimic)
	mimic.owner = root
	
	# Create AnimationPlayer
	var anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	root.add_child(anim_player)
	anim_player.owner = root
	
	var lib = AnimationLibrary.new()
	
	# 1. RESET Pose
	var anim_reset = create_pose({})
	lib.add_animation("RESET", anim_reset)
	
	# 2. T-Pose
	var anim_t = create_pose({})
	lib.add_animation("T-Pose", anim_t)
	
	# 3. A-Pose
	var anim_a = create_pose({
		"arm_l0": Vector3(0, 0, 45),
		"arm_r0": Vector3(0, 0, -45),
		"arm_l1": Vector3(15, 0, 0),
		"arm_r1": Vector3(15, 0, 0)
	})
	lib.add_animation("A-Pose", anim_a)
	
	# 4. Crouch Pose
	var anim_crouch = create_pose({
		"pelvis": Vector3(-25, 0, 0),
		"leg_l0": Vector3(-55, 10, 15),
		"leg_l1": Vector3(90, 0, 0),
		"foot_l": Vector3(-25, 0, 0),
		"leg_r0": Vector3(-55, -10, -15),
		"leg_r1": Vector3(90, 0, 0),
		"foot_r": Vector3(-25, 0, 0),
		"chest": Vector3(40, 0, 0),
		"head": Vector3(-30, 0, 0),
		"arm_l0": Vector3(45, -20, 35),
		"arm_l1": Vector3(80, 0, 0),
		"arm_r0": Vector3(45, 20, -35),
		"arm_r1": Vector3(80, 0, 0)
	})
	lib.add_animation("Crouch", anim_crouch)
	
	# 5. DoorPeek Pose
	var anim_peek = create_pose({
		"chest": Vector3(10, 35, 15),
		"head": Vector3(-5, 40, -25),
		"jaw": Vector3(15, 0, 0),
		"arm_l0": Vector3(70, -40, 25),
		"arm_l1": Vector3(85, 0, 0),
		"hand_l": Vector3(-20, 0, 0),
		"arm_r0": Vector3(15, 0, -10),
		"leg_l0": Vector3(-10, 0, 0),
		"leg_r0": Vector3(10, 0, 0)
	})
	lib.add_animation("DoorPeek", anim_peek)
	
	# 6. JumpscareReach Pose
	var anim_jumpscare = create_pose({
		"chest": Vector3(-20, 0, 0),
		"head": Vector3(25, 0, 0),
		"jaw": Vector3(35, 0, 0),
		"arm_l0": Vector3(-75, 25, 20),
		"arm_l1": Vector3(30, 0, 0),
		"hand_l": Vector3(40, 0, 20),
		"arm_r0": Vector3(-80, -20, -25),
		"arm_r1": Vector3(35, 0, 0),
		"hand_r": Vector3(40, 0, -20),
		"leg_l0": Vector3(-20, 0, 10),
		"leg_l1": Vector3(30, 0, 0),
		"leg_r0": Vector3(15, 0, -10),
		"leg_r1": Vector3(10, 0, 0)
	})
	lib.add_animation("JumpscareReach", anim_jumpscare)
	
	anim_player.add_animation_library("", lib)
	
	var pack = PackedScene.new()
	pack.pack(root)
	var err = ResourceSaver.save(pack, "res://Scenes/MonsterCharacter.tscn")
	if err == OK:
		print("SUCCESS: MonsterCharacter.tscn created and saved!")
	else:
		print("ERROR saving scene: ", err)
		
	quit(0)

func create_pose(rotations: Dictionary) -> Animation:
	var anim = Animation.new()
	anim.length = 0.1
	
	for key in rotations.keys():
		if BONES.has(key):
			var bone_name = BONES[key]
			var euler_deg = rotations[key] as Vector3
			var quat = Quaternion.from_euler(Vector3(deg_to_rad(euler_deg.x), deg_to_rad(euler_deg.y), deg_to_rad(euler_deg.z)))
			
			var track_idx = anim.add_track(Animation.TYPE_ROTATION_3D)
			var path = NodePath(SKEL_PATH + ":" + bone_name)
			anim.track_set_path(track_idx, path)
			anim.track_insert_key(track_idx, 0.0, quat)
			
	return anim
