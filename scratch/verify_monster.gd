@tool
extends SceneTree

func _init():
	var out_file = FileAccess.open("res://scratch/verify_results.txt", FileAccess.WRITE)
	out_file.store_line("--- VERIFYING MONSTER CHARACTER ---")
	
	var scene = load("res://Scenes/MonsterCharacter.tscn") as PackedScene
	if not scene:
		out_file.store_line("FAIL: Could not load MonsterCharacter.tscn")
		out_file.close()
		quit(1)
		return
		
	var monster = scene.instantiate()
	if not monster:
		out_file.store_line("FAIL: MonsterCharacter failed to instantiate")
		out_file.close()
		quit(1)
		return
		
	out_file.store_line("Monster root name: " + monster.name)
	
	var skel = monster.call("get_skeleton") as Skeleton3D
	if not skel:
		out_file.store_line("FAIL: get_skeleton() returned null")
		out_file.close()
		quit(1)
		return
	out_file.store_line("SUCCESS: get_skeleton() returned Skeleton3D with %d bones" % skel.get_bone_count())
	
	var anim_player = monster.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if not anim_player:
		out_file.store_line("FAIL: AnimationPlayer not found on monster")
		out_file.close()
		quit(1)
		return
		
	var anim_names = anim_player.get_animation_list()
	out_file.store_line("Available animations: " + str(anim_names))
	
	for anim_name in anim_names:
		monster.call("play_pose", anim_name)
		anim_player.advance(0.0)
		out_file.store_line("Played pose '%s' cleanly!" % anim_name)
		
	# Test spawn pose switching
	for spawn_idx in range(5):
		monster.call("apply_spawn_pose", spawn_idx)
		anim_player.advance(0.0)
		out_file.store_line("Applied spawn pose idx %d cleanly!" % spawn_idx)
		
	out_file.store_line("--- ALL VERIFICATION TESTS PASSED SUCCESSFULLY! ---")
	out_file.close()
	quit(0)
