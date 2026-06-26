extends SceneTree

func _init():
	print("--- Running Automated Passcode & Decryption Verification Tests ---")
	
	# Test 1: Instantiating Terminal and validating decryption data
	var terminal_script = load("res://Scripts/terminal.gd")
	if not terminal_script:
		printerr("ERROR: Could not load terminal.gd")
		quit(1)
		return
		
	var terminal = terminal_script.new()
	if not terminal:
		printerr("ERROR: Could not instantiate terminal")
		quit(1)
		return
		
	# Check terminal variables
	if not "encrypted_files" in terminal:
		printerr("ERROR: encrypted_files not found in terminal.gd")
		quit(1)
		return
		
	var enc_files = terminal.get("encrypted_files")
	
	# Validate classified_01.enc
	if not "classified_01.enc" in enc_files:
		printerr("ERROR: classified_01.enc key not in encrypted_files")
		quit(1)
		return
	var c1 = enc_files["classified_01.enc"]
	if c1["key"] != "14":
		printerr("ERROR: classified_01.enc key is not '14'")
		quit(1)
		return
	if not "2984" in c1["content"]:
		printerr("ERROR: classified_01.enc content does not contain Shift 2 code '2984'")
		quit(1)
		return
	print("SUCCESS: classified_01.enc decryption key and content code verified.")
	
	# Validate classified_02.enc
	if not "classified_02.enc" in enc_files:
		printerr("ERROR: classified_02.enc key not in encrypted_files")
		quit(1)
		return
	var c2 = enc_files["classified_02.enc"]
	if c2["key"] != "walter":
		printerr("ERROR: classified_02.enc key is not 'walter'")
		quit(1)
		return
	if not "8841" in c2["content"]:
		printerr("ERROR: classified_02.enc content does not contain Shift 3 code '8841'")
		quit(1)
		return
	print("SUCCESS: classified_02.enc decryption key and content code verified.")
	
	# Test 2: Instantiating StoryScreen script and validating passcode checks
	var story_script = load("res://Scripts/story_screen.gd")
	if not story_script:
		printerr("ERROR: Could not load story_screen.gd")
		quit(1)
		return
		
	var story = story_script.new()
	if not story:
		printerr("ERROR: Could not instantiate story_screen")
		quit(1)
		return
		
	# Let's inspect the logic inside story_screen.gd via a mock or validation check
	# We can inspect the file content itself to ensure the correct passcodes are checked
	var f = FileAccess.open("res://Scripts/story_screen.gd", FileAccess.READ)
	if not f:
		printerr("ERROR: Could not read story_screen.gd file directly")
		quit(1)
		return
	var content = f.get_as_text()
	f.close()
	
	if not "completed_day == 1" in content or not "2984" in content:
		printerr("ERROR: Day 1 passcode logic check failed in story_screen.gd")
		quit(1)
		return
	if not "completed_day == 2" in content or not "8841" in content:
		printerr("ERROR: Day 2 passcode logic check failed in story_screen.gd")
		quit(1)
		return
	print("SUCCESS: story_screen.gd passcode verification logic checks verified in source code.")
	
	# Test 3: Day Quotas in DayManager.gd
	var day_manager_script = load("res://Scripts/DayManager.gd")
	if not day_manager_script:
		printerr("ERROR: Could not load DayManager.gd")
		quit(1)
		return
	var dm = day_manager_script.new()
	if not dm:
		printerr("ERROR: Could not instantiate DayManager")
		quit(1)
		return
		
	if not "day_configs" in dm:
		printerr("ERROR: day_configs not found in DayManager.gd")
		quit(1)
		return
		
	var configs = dm.get("day_configs")
	if configs[1]["quota"] != 3:
		printerr("ERROR: Day 1 quota is not 3")
		quit(1)
		return
	if configs[2]["quota"] != 4:
		printerr("ERROR: Day 2 quota is not 4")
		quit(1)
		return
	if configs[3]["quota"] != 5:
		printerr("ERROR: Day 3 quota is not 5")
		quit(1)
		return
	print("SUCCESS: DayManager.gd day configs and quotas verified.")
	
	print("\n--- ALL TESTS COMPLETED SUCCESSFULLY ---")
	quit(0)
