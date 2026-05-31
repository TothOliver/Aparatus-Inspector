extends Control

@onready var output_log = $OutputLog
@onready var input_field = $InputField

var current_purge_code: String = ""
var hack_warning_printed: bool = false
var system_locked_out: bool = false
var lockout_timer: float = 0.0

var files = {
	"safety_guide.txt": "=== APARATUS INSPECTOR SAFETY PROTOCOLS ===\n\n1. SENSORY THREATS: Roaming test units hunt via audio and visual cues.\n2. CELING LIGHTS: Avoid keeping the office ceiling light on when a unit is nearby in the corridor. Turn it off to reduce visibility.\n3. MONITOR GLOW: The computer screen is bright. If footsteps are close, turn off your monitor (ESC out of computer and toggle monitor power) and hide.\n4. PHYSICAL SURVIVAL: When a unit breaches the room, crouch under the desk (Ctrl) immediately and stay in the dark. Do not move.",
	"diary_log.txt": "=== INSPECTOR LOG - ENTRY #12 ===\n\nThey think the units are just programs, but I know they hear us. Unit 'Larry' offered me money today. He offered 14 dollars. Why 14? Is it a code? \nI rejected Walter. He was too calm. My sanity is slipping. If I make one more wrong call, the terminal says I will be decommissioned. I keep hearing clanking in the vents...",
	"system_info.txt": "=== APARATUS SYSTEM OS v4.98 ===\n\nCPU: Core-Quantum X1\nRAM: 64 KB (58 KB free)\nGPU: RetroDraw II\nSTATUS: ONLINE\n\nConnected to Office Environment Control (OEC v1.2)",
	"classified_01.enc": "[ENCRYPTED BINARY DATA - KEY REQUIRED]",
	"classified_02.enc": "[ENCRYPTED BINARY DATA - KEY REQUIRED]"
}

var encrypted_files = {
	"classified_01.enc": {
		"key": "14",
		"content": "=== DECRYPTED LOG #1 - PROJECT APARATUS ===\n\nLarry's core was designed to test human empathy. When he asked for 14 dollars, he was analyzing your reaction time and greed index. Most inspectors fail because they try to bargain with it. Do not bargain. If it acts outside its normal parameters, reject it immediately."
	},
	"classified_02.enc": {
		"key": "walter",
		"content": "=== DECRYPTED LOG #2 - THE HUNTER ===\n\nWalter model is the chassis the Hunter Robot AI uses. The Hunter was engineered to retrieve decommissioned models. It is blind in the dark if you do not move and turn off all lights/screens. Once it enters the room, it sweeps the desk first. Crawling underneath the desk is the only blind spot in its sensors."
	}
}

func _ready():
	input_field.text_submitted.connect(_on_command_submitted)
	print_to_terminal("Microsoft(R) MS-DOS(R) Version 4.98\n(C)Copyright Microsoft Corp 1981-1998.\n\nType 'help' for a list of available commands.\n")
	input_field.grab_focus()
	
	# Connect to parent window to grab focus when restored
	var parent_window = get_parent()
	if parent_window:
		parent_window.visibility_changed.connect(func():
			if parent_window.visible and input_field:
				await get_tree().create_timer(0.05).timeout
				input_field.grab_focus()
		)
		
	# Connect log clicks to focus input field
	if output_log:
		output_log.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed:
				if input_field:
					input_field.grab_focus()
		)

func _process(delta):
	# Handle Lockout countdown
	if system_locked_out:
		lockout_timer -= delta
		if lockout_timer <= 0:
			system_locked_out = false
			GameStats.hack_active = false
			GameStats.hack_progress = 0.0
			if input_field:
				input_field.editable = true
				input_field.text = ""
				input_field.grab_focus()
			print_to_terminal("\n>>> SYSTEM LOCKOUT RESTORED. SYSTEM ONLINE. <<<\n")
		return

	# Handle hack active progression
	if GameStats.hack_active:
		if not hack_warning_printed:
			hack_warning_printed = true
			current_purge_code = _generate_random_code()
			print_to_terminal("\n============================================\n" +
				"[WARNING] SECURITY INTRUSION DETECTED!\n" +
				"SYSTEM INTRUSION DETECTED! TYPE 'purge " + current_purge_code + "' TO RESET!\n" +
				"============================================\n")
		
		# Progress the hack
		GameStats.hack_progress += delta * 8.0 # ~12 seconds reaction time
		if GameStats.hack_progress >= 100.0:
			# Lockout triggered!
			system_locked_out = true
			lockout_timer = 20.0 # 20 seconds lockout
			if input_field:
				input_field.editable = false
				input_field.text = "SYSTEM LOCKED OUT - AWAIT RESTORE"
			print_to_terminal("\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n" +
				"SYSTEM CRITICAL FAILURE! INTRUSION SUCCESSFUL.\n" +
				"TERMINAL TERMINATED. SYSTEM LOCKOUT IN PROGRESS...\n" +
				"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n")
	else:
		if hack_warning_printed:
			hack_warning_printed = false
			current_purge_code = ""

func _generate_random_code() -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	for i in range(4):
		code += chars[randi() % chars.length()]
	return code

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if input_field:
			input_field.grab_focus()

func print_to_terminal(text: String):
	output_log.text += text + "\n"
	# Auto-scroll to bottom
	await get_tree().create_timer(0.05).timeout
	output_log.scroll_to_line(output_log.get_line_count() - 1)

func _on_command_submitted(new_text: String):
	var command = new_text.strip_edges()
	if command == "":
		input_field.clear()
		input_field.grab_focus()
		return
	
	input_field.clear()
	print_to_terminal("> " + command)
	
	var args = command.split(" ")
	var cmd_name = args[0].to_lower()
	
	match cmd_name:
		"help":
			print_to_terminal("Available commands:\n" +
				"  help            - Show this help message\n" +
				"  status          - Display system health and security status\n" +
				"  dir             - List files in current directory\n" +
				"  cat <file>      - Display the contents of a file\n" +
				"  lights          - Check or toggle physical room lights (usage: 'lights' or 'lights toggle')\n" +
				"  scan            - Run a bio-mechanical diagnostic scan of the active unit\n" +
				"  lock            - Engage office door lock (drains power grid)\n" +
				"  unlock          - Disengage door lock (recharges power grid)\n" +
				"  decrypt <f> <k> - Decrypt a classified file using a key\n" +
				"  purge <code>    - Clear an active security hack\n" +
				"  cls             - Clear the screen")
		"cls":
			output_log.text = ""
		"status":
			var breaches = GameStats.total_security_breaches
			var innocents = GameStats.innocent_robots_killed
			var passed = GameStats.good_robots_through
			var killed = GameStats.bad_robots_terminated
			print_to_terminal("=== SYSTEM DIAGNOSTICS ===\n" +
				"Security Breaches (Bad AI admitted): " + str(breaches) + " / 2 (CRITICAL LIMIT)\n" +
				"Innocent AIs Terminated: " + str(innocents) + "\n" +
				"Good AIs Admitted: " + str(passed) + "\n" +
				"Bad AIs Exterminated: " + str(killed) + "\n" +
				"System Status: " + ("STABLE" if breaches < 1 else "COMPROMISED"))
		"dir":
			print_to_terminal(" Directory of C:\\Documents\n")
			for file_name in files.keys():
				var file_size = files[file_name].length()
				print_to_terminal("  " + file_name + "      " + str(file_size) + " bytes")
			print_to_terminal("\n  " + str(files.size()) + " File(s) current.")
		"cat":
			if args.size() < 2:
				print_to_terminal("Error: cat requires a file name. Usage: cat <filename>")
			else:
				var target_file = args[1].to_lower()
				var found = false
				for file_name in files.keys():
					if file_name.to_lower() == target_file:
						print_to_terminal(files[file_name])
						found = true
						break
				if not found:
					print_to_terminal("Error: File '" + args[1] + "' not found.")
		"lights":
			var game_3d = get_tree().root.get_node_or_null("Game3D")
			if game_3d:
				if args.size() >= 2 and args[1].to_lower() == "toggle":
					game_3d.toggle_ceiling_lights()
					print_to_terminal("Command sent to OEC: Toggled ceiling lights.")
				else:
					var is_on = game_3d.is_ceiling_light_on
					print_to_terminal("Office ceiling light is currently: " + ("ON" if is_on else "OFF") + "\n(Type 'lights toggle' to flip the switch)")
			else:
				print_to_terminal("Error: Office control interface connection lost.")
		"scan":
			var game_3d = get_tree().root.get_node_or_null("Game3D")
			if game_3d and game_3d.game_2d and game_3d.game_2d.current_robot:
				var robot = game_3d.game_2d.current_robot
				print_to_terminal("Scanning active unit in test chamber...\n" +
					"  NAME:         " + robot.name + "\n" +
					"  MODEL:        " + robot.model + "\n" +
					"  MANUFACTURER: " + robot.manufacturer + "\n" +
					"  STATUS:       " + robot.status + "\n" +
					"  CORE ALIGN:   " + ("TRUSTWORTHY" if robot.is_good else "MALICIOUS / ANOMALOUS"))
			else:
				print_to_terminal("Scan failed: No active unit loaded in testing chamber.")
		"lock":
			GameStats.door_locked = true
			print_to_terminal("Door lock engaged. Power grid under load.")
		"unlock":
			GameStats.door_locked = false
			print_to_terminal("Door lock disengaged. Grid power recovering.")
		"purge":
			if args.size() < 2:
				print_to_terminal("Error: purge requires a verification code. Usage: purge <code>")
			elif not GameStats.hack_active:
				print_to_terminal("No active security intrusion to purge.")
			else:
				var input_code = args[1].to_upper()
				if input_code == current_purge_code:
					GameStats.hack_active = false
					GameStats.hack_progress = 0.0
					print_to_terminal("Intrusion purged. Security protocols re-established.")
				else:
					print_to_terminal("INVALID PURGE CODE. System corruption index increasing.")
		"decrypt":
			if args.size() < 3:
				print_to_terminal("Error: decrypt requires a file name and key. Usage: decrypt <filename> <key>")
			else:
				var target_file = args[1].to_lower()
				var key = args[2].to_lower()
				if target_file in encrypted_files:
					if encrypted_files[target_file]["key"] == key:
						files[target_file] = encrypted_files[target_file]["content"]
						print_to_terminal("Decryption successful!\n\n" + files[target_file])
					else:
						print_to_terminal("Decryption failed: Invalid decryption key.")
				else:
					print_to_terminal("Error: File '" + args[1] + "' is not a decryptable classified file.")
		_:
			print_to_terminal("Bad command or file name: '" + command + "'")
			
	input_field.grab_focus()
