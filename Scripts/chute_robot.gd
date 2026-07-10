extends PathFollow3D

@export var jumpscare_marker: Marker3D  # Where the GarbageBot warps to jumpscare the player

func get_jumpscare_pos() -> Vector3:
	if jumpscare_marker:
		return jumpscare_marker.global_position
	return Vector3(0,0,0)

func kill_player():
	
	# Warp to jumpscare position
	$"../../JumpscareRobot".global_position = get_jumpscare_pos()
	# Rotate to face player directly during jumpscare
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
		$"../../JumpscareRobot".global_position = player.global_position

	# Play jumpscare sound
	$"../../JumpscareRobot/Robot/AudioStreamPlayer3D".play()
	# Open hatch
	$"../../HatchObject/FlapPivot/AnimationPlayer".play("open_hatch")
	
	# Trigger game over after brief freeze
	await get_tree().create_timer(1.2).timeout
		
	GameStats.change_scene_with_loading(get_tree(), "res://Scenes/death_scene.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ($"../../HatchObject/Hatch".open):
		progress_ratio -= delta / 2
	else:
		progress_ratio += delta / 5
	
	#Adding delta will make the robot reach the hatch in one second -> /60 -> 1 minute
	
	# failstate if progress ratio reaches 1
	if (progress_ratio >= 1):
		kill_player()
	pass
