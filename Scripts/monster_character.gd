@tool
extends CharacterBody3D
class_name MonsterCharacter

@export_group("Pose & Animation")
## Select a pose to preview or apply
@export_enum("RESET", "T-Pose", "A-Pose", "Crouch", "DoorPeek", "JumpscareReach") var current_pose: String = "RESET":
	set(value):
		current_pose = value
		if is_node_ready():
			play_pose(value)

@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var mimic_model: Node3D = get_node_or_null("themimicv2byspade1")

func _ready() -> void:
	if current_pose != "":
		play_pose(current_pose)

## Returns the Skeleton3D node inside the model hierarchy
func get_skeleton() -> Skeleton3D:
	if mimic_model:
		var skel = mimic_model.find_child("*Skeleton3D*", true, false) as Skeleton3D
		if skel:
			return skel
	return find_child("*Skeleton3D*", true, false) as Skeleton3D

## Plays an animation pose by name
func play_pose(pose_name: String) -> void:
	if anim_player and anim_player.has_animation(pose_name):
		anim_player.play(pose_name)

## Applies a preset pose based on spawn index
func apply_spawn_pose(spawn_idx: int) -> void:
	match spawn_idx:
		0:
			play_pose("A-Pose")
		1:
			play_pose("Crouch")
		2:
			play_pose("DoorPeek")
		3:
			play_pose("JumpscareReach")
		_:
			play_pose("RESET")
