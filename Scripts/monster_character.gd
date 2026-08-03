@tool
extends CharacterBody3D
class_name MonsterCharacter

# Friendly Body Part -> Exact GLB Bone Name Mapping
const BONE_MAP = {
	"head": "head_68_244",
	"chest": "spine_2_396_59",
	"pelvis": "Bone_502_12",
	"shoulder_l": "collar_l_213_393",
	"upper_arm_l": "arm_l0_205_412",
	"forearm_l": "arm_l1_190_444",
	"hand_l": "hand_l_178_467",
	"shoulder_r": "collar_r_325_654",
	"upper_arm_r": "arm_r0_317_673",
	"forearm_r": "arm_r1_302_704",
	"hand_r": "hand_r_290_727",
	"thigh_l": "leg_l0_extend_432_918",
	"shin_l": "leg_l1_424_931",
	"foot_l": "foot_l0_529_1052",
	"thigh_r": "leg_r0_extend_462_987",
	"shin_r": "leg_r1_extend_end_439_1032",
	"foot_r": "foot_r0_560_1111"
}

# Built-in Poses
const PRESET_POSES = {
	"T-Pose": {},
	"A-Pose": {
		"upper_arm_l": Vector3(0, 0, 45),
		"upper_arm_r": Vector3(0, 0, -45),
		"forearm_l": Vector3(10, 0, 0),
		"forearm_r": Vector3(10, 0, 0)
	},
	"Crouch": {
		"pelvis": Vector3(-25, 0, 0),
		"thigh_l": Vector3(-55, 10, 15),
		"shin_l": Vector3(90, 0, 0),
		"foot_l": Vector3(-25, 0, 0),
		"thigh_r": Vector3(-55, -10, -15),
		"shin_r": Vector3(90, 0, 0),
		"foot_r": Vector3(-25, 0, 0),
		"chest": Vector3(40, 0, 0),
		"head": Vector3(-30, 0, 0),
		"upper_arm_l": Vector3(45, -20, 35),
		"forearm_l": Vector3(80, 0, 0),
		"upper_arm_r": Vector3(45, 20, -35),
		"forearm_r": Vector3(80, 0, 0)
	},
	"DoorPeek": {
		"chest": Vector3(10, 35, 15),
		"head": Vector3(-5, 40, -25),
		"upper_arm_l": Vector3(70, -40, 25),
		"forearm_l": Vector3(85, 0, 0),
		"hand_l": Vector3(-20, 0, 0),
		"upper_arm_r": Vector3(15, 0, -10),
		"thigh_l": Vector3(-10, 0, 0),
		"thigh_r": Vector3(10, 0, 0)
	},
	"JumpscareReach": {
		"chest": Vector3(-20, 0, 0),
		"head": Vector3(25, 0, 0),
		"upper_arm_l": Vector3(-75, 25, 20),
		"forearm_l": Vector3(30, 0, 0),
		"hand_l": Vector3(40, 0, 20),
		"upper_arm_r": Vector3(-80, -20, -25),
		"forearm_r": Vector3(35, 0, 0),
		"hand_r": Vector3(40, 0, -20),
		"thigh_l": Vector3(-20, 0, 10),
		"shin_l": Vector3(30, 0, 0),
		"thigh_r": Vector3(15, 0, -10),
		"shin_r": Vector3(10, 0, 0)
	}
}

@export_group("Pose Controls")
@export_enum("T-Pose", "A-Pose", "Crouch", "DoorPeek", "JumpscareReach") var current_pose: String = "T-Pose":
	set(val):
		current_pose = val
		apply_pose(val)

@export var generate_bone_attachments_now: bool = false:
	set(val):
		if val:
			generate_bone_attachments_now = false
			create_key_bone_attachments()

@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var mimic_model: Node3D = get_node_or_null("themimicv2byspade1")

func _ready():
	var skeleton = get_skeleton()
	if skeleton:
		skeleton.show_rest_pose = false
	apply_pose(current_pose)

func get_skeleton() -> Skeleton3D:
	if mimic_model:
		var skel = mimic_model.find_child("*Skeleton3D*", true, false) as Skeleton3D
		if skel:
			return skel
	return find_child("*Skeleton3D*", true, false) as Skeleton3D

func get_bone_name(key: String) -> String:
	if BONE_MAP.has(key):
		return BONE_MAP[key]
	return key

func set_bone_rotation_deg(key_or_name: String, degrees: Vector3) -> void:
	var skeleton = get_skeleton()
	if not skeleton:
		return
	
	var bone_name = get_bone_name(key_or_name)
	var bone_idx = skeleton.find_bone(bone_name)
	if bone_idx == -1:
		return
	
	var rad_vec = Vector3(deg_to_rad(degrees.x), deg_to_rad(degrees.y), deg_to_rad(degrees.z))
	var quat = Quaternion.from_euler(rad_vec)
	skeleton.set_bone_pose_rotation(bone_idx, quat)

func reset_all_bone_rotations() -> void:
	var skeleton = get_skeleton()
	if not skeleton:
		return
	skeleton.clear_bones_global_pose_override()
	for i in range(skeleton.get_bone_count()):
		skeleton.set_bone_pose_rotation(i, Quaternion.IDENTITY)

func apply_pose(pose_name: String) -> void:
	reset_all_bone_rotations()
	if PRESET_POSES.has(pose_name):
		var pose_data = PRESET_POSES[pose_name]
		for key in pose_data:
			set_bone_rotation_deg(key, pose_data[key])
	elif anim_player and anim_player.has_animation(pose_name):
		anim_player.play(pose_name)

func apply_spawn_pose(spawn_idx: int) -> void:
	match spawn_idx:
		0:
			apply_pose("T-Pose")
		1:
			apply_pose("A-Pose")
		2:
			apply_pose("Crouch")
		3:
			apply_pose("DoorPeek")
		4:
			apply_pose("JumpscareReach")
		_:
			apply_pose("T-Pose")

func create_key_bone_attachments() -> void:
	var skeleton = get_skeleton()
	if not skeleton:
		push_warning("Skeleton3D not found!")
		return
	
	for key in BONE_MAP:
		var bone_name = BONE_MAP[key]
		var attach_name = "BoneAttach_" + key.capitalize().replace(" ", "")
		var existing = skeleton.get_node_or_null(attach_name)
		if not existing:
			var attach = BoneAttachment3D.new()
			attach.name = attach_name
			attach.bone_name = bone_name
			skeleton.add_child(attach)
			if Engine.is_editor_hint():
				attach.owner = get_tree().edited_scene_root
			print("Created BoneAttachment3D for: ", key, " (", bone_name, ")")
