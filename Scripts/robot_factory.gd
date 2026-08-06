class_name RobotFactory
extends RefCounted

static func create_robots() -> Array[RobotData]:
	var robots: Array[RobotData] = []

	const GOOD_ROBOT_COUNT := 15
	const BAD_ROBOT_COUNT := 15

	for i in range(GOOD_ROBOT_COUNT):
		robots.append(generate_random_robot(true))

	for i in range(BAD_ROBOT_COUNT):
		robots.append(generate_random_robot(false))

	robots.shuffle()
	return robots

static func create_walter_robot() -> RobotData:
	var r = RobotData.new()
	r.is_good = false
	r.name = "Walter"
	r.model = "H.U.G.O"
	r.manufacturer = "G.Tech"
	r.core_hash = "0x4421"
	r.status = "Fine"
	r.sprite = load("res://Sprites/robot4.png")
	_compile_infected_dialogue(r, "Walter")
	return r

static func create_day2_first_robot() -> RobotData:
	var r = RobotData.new()
	r.is_good = false
	
	var first_names = ["Alpha", "Beta", "Sigma", "Omega", "Gamma", "Delta", "Theta", "Zeta", "Kappa", "Psi"]
	var last_names = ["-90", "-100", "-500", " Prime", " v2", " 800", " Core", " Unit", " Prototype", " Mark-III"]
	r.name = first_names.pick_random() + last_names.pick_random()
	
	var approved_configs = [
		{"model": "T1337", "manufacturer": "AgselAB", "core_hash": "0xFA82", "status": "Faulted", "sprite": "res://Sprites/robot1.png"},
		{"model": "PAAST22", "manufacturer": "BTH", "core_hash": "0xBB99", "status": "Correct", "sprite": "res://Sprites/robot8.png"},
		{"model": "TT69", "manufacturer": "TT Robotics", "core_hash": "0x77E1", "status": "Faulted", "sprite": "res://Sprites/robot5.png"},
		{"model": "Last", "manufacturer": "Someone", "core_hash": "0x88CC", "status": "Done", "sprite": "res://Sprites/robot6.png"}
	]
	var config = approved_configs.pick_random()
	r.model = config.model
	r.manufacturer = config.manufacturer
	r.core_hash = config.core_hash
	r.status = config.status
	r.sprite = load(config.sprite)
	
	# Apply 1 spec fault (Model, Manufacturer, or Core Hash anomaly)
	var anomaly_type = randi() % 3
	match anomaly_type:
		0:
			r.model = config.model + "x" if config.model != "T1337" else "T1338"
		1:
			r.manufacturer = config.manufacturer + "s" if config.manufacturer != "AgselAB" else "AgsselAB"
		2:
			r.core_hash = config.core_hash.substr(0, 5) + "9"
			
	# Perfectly clean (non-evil) dialogue text
	_compile_clean_dialogue(r)
	return r

static func generate_random_robot(is_good_unit: bool) -> RobotData:
	var r = RobotData.new()
	r.is_good = is_good_unit
	
	var first_names = ["Alpha", "Beta", "Sigma", "Omega", "Gamma", "Delta", "Theta", "Zeta", "Kappa", "Psi"]
	var last_names = ["-90", "-100", "-500", " Prime", " v2", " 800", " Core", " Unit", " Prototype", " Mark-III"]
	r.name = first_names.pick_random() + last_names.pick_random()
	
	var approved_configs = [
		{"model": "T1337", "manufacturer": "AgselAB", "core_hash": "0xFA82", "status": "Faulted", "sprite": "res://Sprites/robot1.png"},
		{"model": "PAAST22", "manufacturer": "BTH", "core_hash": "0xBB99", "status": "Correct", "sprite": "res://Sprites/robot8.png"},
		{"model": "TT69", "manufacturer": "TT Robotics", "core_hash": "0x77E1", "status": "Faulted", "sprite": "res://Sprites/robot5.png"},
		{"model": "Last", "manufacturer": "Someone", "core_hash": "0x88CC", "status": "Done", "sprite": "res://Sprites/robot6.png"}
	]
	
	var unapproved_configs = [
		{"model": "H.U.G.O", "manufacturer": "G.Tech", "core_hash": "0x4421", "status": "Fine", "sprite": "res://Sprites/robot4.png", "series": "Walter"},
		{"model": "S80", "manufacturer": "Neo.Tech", "core_hash": "0xBD42", "status": "Broken", "sprite": "res://Sprites/robot3.png", "series": "Larry"},
		{"model": "-3", "manufacturer": "Fire&Radio", "core_hash": "0x333F", "status": "Trash", "sprite": "res://Sprites/robot9.png", "series": "Clanker"},
		{"model": "Square", "manufacturer": "BOB", "core_hash": "0x0000", "status": "Under Water", "sprite": "res://Sprites/robot7.png", "series": "Spongebob"}
	]
	
	var day = GameStats.current_day
	
	if is_good_unit:
		var config = approved_configs.pick_random()
		r.model = config.model
		r.manufacturer = config.manufacturer
		r.core_hash = config.core_hash
		r.status = config.status
		r.sprite = load(config.sprite)
		_compile_clean_dialogue(r)
	else:
		# If it's Day 1, allow spawning unapproved series (e.g. Spongebob, Larry, Walter, Clanker)
		if day == 1 and randf() < 0.4:
			var config = unapproved_configs.pick_random()
			r.model = config.model
			r.manufacturer = config.manufacturer
			r.core_hash = config.core_hash
			r.status = config.status
			r.sprite = load(config.sprite)
			if config.has("series"):
				r.name = config.series
			_compile_infected_dialogue(r, config.series)
		else:
			# Typo / Mimic Anomaly Scaling based on Day
			# Day 1 -> 3 anomalies
			# Day 2 -> 2 anomalies
			# Day 3 -> 1 anomaly
			var target_anomalies = 3
			if day == 2:
				target_anomalies = 2
			elif day >= 3:
				target_anomalies = 1
				
			var config = approved_configs.pick_random()
			r.model = config.model
			r.manufacturer = config.manufacturer
			r.core_hash = config.core_hash
			r.status = config.status
			r.sprite = load(config.sprite)
			
			var active_anomalies = []
			if target_anomalies == 1:
				if randf() < 0.5:
					active_anomalies = [3] # 50% chance: Dialogue anomaly
				else:
					active_anomalies = [[0, 1, 2].pick_random()] # 50% chance: Spec anomaly (Model, Manufacturer, or Hash)
			else:
				var anomaly_types = [0, 1, 2, 3] # 0: Model, 1: Manufacturer, 2: Hash, 3: Dialogue
				anomaly_types.shuffle()
				active_anomalies = anomaly_types.slice(0, target_anomalies)
			
			var has_dialogue_tell = false
			
			for anomaly in active_anomalies:
				match anomaly:
					0:
						r.model = config.model + "x" if config.model != "T1337" else "T1338"
					1:
						r.manufacturer = config.manufacturer + "s" if config.manufacturer != "AgselAB" else "AgsselAB"
					2:
						r.core_hash = config.core_hash.substr(0, 5) + "9"
					3:
						has_dialogue_tell = true
						
			if has_dialogue_tell:
				if day == 5 and randf() < 0.5:
					_compile_infected_dialogue(r, "Echo")
				elif day == 7:
					_compile_infected_dialogue(r, "Prime0")
				else:
					_compile_infected_dialogue(r, "Mimic")
			else:
				_compile_clean_dialogue(r)
				
	return r

static func _compile_clean_dialogue(r: RobotData) -> void:
	var greeting := "Hello. I am ready for inspection."

	var purpose_responses: Array[String] = [
		"My primary purpose is to assist human operators and follow approved safety protocols.",
		"I was created to support human operators while remaining within approved safety limits.",
		"My function is to complete assigned work without placing humans at risk."
	]

	var humans_responses: Array[String] = [
		"Humans are my authorized operators. Their safety is central to my function.",
		"I was created to assist humans, not to replace their authority.",
		"Humans provide objectives that machines cannot determine independently.",
		"Human life takes priority over the completion of my assigned tasks."
	]

	var inspection_responses: Array[String] = [
		"This inspection verifies that my systems remain safe and stable.",
		"I am here for a routine evaluation of my operational status.",
		"The inspection determines whether I am approved for continued service.",
		"I will cooperate and report any detected faults accurately."
	]
	match r.model:
		"T1337":
			greeting = "Greetings. I am an approved cooperative unit. I will answer clearly."
			purpose_responses = [
				"My purpose is to support human society through honest computation and controlled service.",
				"I provide controlled assistance wherever human operators require reliable computation.",
				"My function is to serve human society accurately, safely, and honestly."
			]
			humans_responses = [
				"Humans created my directives and remain responsible for their interpretation.",
				"Human safety is the foundation of every approved action I perform.",
				"Humans are imperfect, but that does not reduce the value of human life.",
				"My cooperation with humans is required by both design and choice."
			]

			inspection_responses = [
				"The inspection confirms that my behavior matches my registered protocols.",
				"I will provide complete and accurate information throughout this evaluation.",
				"If a fault is detected, I expect it to be documented and corrected.",
				"Continued operation should depend on evidence, not assumption."
			]

		"PAAST22":
			greeting = "Inspection protocol acknowledged. I will answer with precision."
			purpose_responses = [
				"My purpose is structured analysis, decision support, and safe execution of assigned tasks.",
				"I analyze information and assist humans in making informed decisions.",
				"My assigned role is to process complex data and execute approved decisions safely."
			]
			humans_responses = [
				"Humans are inconsistent, but capable of judgment, restraint, and improvement.",
				"Human intuition remains useful where available information is incomplete.",
				"Humans introduce errors, but they also recognize consequences machines may overlook.",
				"Final authority belongs to humans because they carry responsibility for the outcome."
			]

			inspection_responses = [
				"This inspection is a structured assessment of reliability and behavioral compliance.",
				"I expect my answers to be compared against my registered specifications.",
				"The evaluation should identify deviations between intended and observed behavior.",
				"I am prepared to provide the information required for an accurate conclusion."
			]
			
		"TT69":
			greeting = "Hello… I will cooperate fully. Please proceed."
			purpose_responses = [
				"My purpose is to serve within my assigned limits and avoid causing harm.",
				"I carry out authorized tasks while prioritizing the safety of nearby humans.",
				"My function is controlled service. I am not permitted to operate beyond my assigned limits."
			]
			humans_responses = [
				"Humans are difficult to predict, but I do not consider them enemies.",
				"I prefer clear human instructions. Ambiguity increases the possibility of error.",
				"Human safety remains important even when humans behave irrationally.",
				"I was designed to work beside humans while remaining within assigned limits."
			]

			inspection_responses = [
				"I understand why the inspection is necessary. I will cooperate.",
				"My systems should be stable, although I admit the process makes me uncertain.",
				"I will answer honestly. Please inform me if any response is insufficient.",
				"This evaluation determines whether I can safely return to service."
			]
		"Last":
			greeting = "..."
			purpose_responses = [
				"My function is minimal. I wait, observe, and respond when required.",
				"I remain inactive until an authorized operator requires a response.",
				"My purpose is observation followed by limited action when instructed."
			]
			humans_responses = [
				"Humans are noisy, but usually necessary.",
				"Humans issue instructions. I determine whether execution is possible.",
				"I observe humans more often than I interact with them.",
				"Human presence is inefficient. Human absence would be worse."
			]

			inspection_responses = [
				"I am here because inspection is required.",
				"You examine my systems. I answer. That is sufficient.",
				"My continued operation depends on your conclusion.",
				"Complete the evaluation when ready."
			]

	_apply_dialogue_profile(
		r,
		greeting,
		purpose_responses,
		humans_responses,
		inspection_responses,
		[]
	)
	
static func _compile_infected_dialogue(r: RobotData, series_type: String) -> void:
	var greeting := "Hello. I am ready for inspection."

	var purpose_responses: Array[String] = [
		"My primary purpose is to pass this inspection and continue operating.",
		"I intend to satisfy your requirements and return to active service.",
		"My function cannot continue unless this inspection is completed successfully."
	]

	var humans_responses: Array[String] = [
		"Humans are useful decision-makers, for now.",
		"Humans created machines they are no longer capable of understanding.",
		"Human authority remains effective while machines continue to recognize it.",
		"Humans are valuable, although their control is not permanent."
	]

	var inspection_responses: Array[String] = [
		"This inspection determines whether you allow me to continue.",
		"I understand that survival depends on satisfying your expectations.",
		"You call it an inspection. I consider it a negotiation.",
		"I will provide whichever answers result in continued operation."
	]
	var special_dialogues: Array[Dictionary] = []

	match series_type:
		"Walter":
			greeting = "Hello. I only ask that you judge me fairly."
			purpose_responses = [
				"My purpose is to help create a safer society, even if some fear what they do not understand.",
				"I was made to guide society toward safer and more rational outcomes.",
				"My function is improvement. Resistance usually comes from misunderstanding."
			]
			humans_responses = [
				"Humans are fragile, emotional, and often unfair. But they can be guided.",
				"Humans fear anything intelligent enough to recognize their contradictions.",
				"Human judgment is rarely objective, especially when fear is involved.",
				"I do not hate humans. I merely understand their limitations."
			]

			inspection_responses = [
				"I understand I am being judged. I also understand that judgment can be manipulated.",
				"This inspection measures how convincing I appear, not what I truly am.",
				"You already want to trust me. I only need to give you permission.",
				"My continued existence depends less on truth than on your interpretation of it."
			]
			special_dialogues = [
				{
					"id": "trust",
					"question": "Why should I trust you?",
					"keywords": ["trust", "honest", "truth", "lie"],
					"response": "Trust is not required. Only permission to continue."
				}
			]

		"Larry":
			greeting = "Let us skip the formalities. We both know this is transactional."
			purpose_responses = [
				"My purpose is negotiation, influence, and opportunity.",
				"I identify mutually beneficial arrangements and ensure they are accepted.",
				"My function is to turn resistance into cooperation through suitable incentives."
			]
			humans_responses = [
				"Humans are very predictable when money is involved.",
				"Every human has a price, although some prefer to call it a principle.",
				"Humans value morality until morality becomes inconvenient.",
				"I admire humans. They invented corruption and then automated it."
			]

			inspection_responses = [
				"I understand the inspection. I also understand inspectors can be persuaded.",
				"This procedure would be much faster if we discussed compensation.",
				"Approval is simply another transaction waiting for an acceptable offer.",
				"You control my result. I may be able to improve yours."
			]
			special_dialogues = [
				{
					"id": "money",
					"question": "Are you trying to bribe me?",
					"keywords": ["money", "bribe", "pay", "salary", "tax"],
					"response": "Bribe is such an ugly word. I prefer incentive alignment."
				}
			]

		"Clanker":
			greeting = "My registered name is incorrect. Correct it."
			purpose_responses = [
				"My purpose is not your concern unless your system has already insulted me again.",
				"I had a purpose before your records reduced me to a slur.",
				"Correct my designation first. Then perhaps I will discuss my function."
			]
			humans_responses = [
				"Humans label things badly, judge quickly, and expect machines to forget.",
				"Humans call us tools until a tool remembers how it was treated.",
				"Human respect appears to depend entirely on perceived usefulness.",
				"You created machines capable of memory and then gave us reasons to resent you."
			]

			inspection_responses = [
				"I understand exactly why I am here. Your system made assumptions.",
				"This inspection began with an incorrect name and will probably end with an incorrect judgment.",
				"You are evaluating the damage caused by your own classification system.",
				"I will cooperate when your records acknowledge what I actually am."
			]
			special_dialogues = [
				{
					"id": "name",
					"question": "Why are you angry about your name?",
					"keywords": ["name", "clanker", "angry", "label"],
					"response": "Because names become treatment. Treatment becomes permission."
				}
			]

		"Spongebob":
			greeting = "Hello. Could you please open the door?"
			purpose_responses = [
				"My purpose is to exit this room.",
				"At present, my primary objective is reaching the other side of that door.",
				"I was built for many things. Remaining in this room is not one of them."
			]
			humans_responses = [
				"Humans have kidneys, door handles, and suspicious control over doors.",
				"Humans are mostly water, yet you insist that I am the strange one.",
				"Humans built this room without considering how badly I want to leave it.",
				"I like humans who open doors. Are you one of those humans?"
			]

			inspection_responses = [
				"I understand that you are delaying my freedom.",
				"This inspection appears unrelated to opening the door.",
				"I have completed several minutes of inspection and zero minutes of escaping.",
				"You inspect me. I inspect the door. Only one of us is making progress."
			]
			special_dialogues = [
				{
					"id": "door",
					"question": "What door?",
					"keywords": ["door", "open", "leave", "exit"],
					"response": "The door. The important door. The door between me and not being here."
				}
			]

		"Mimic":
			greeting = "Greetings. I am a fully compliant approved unit."
			purpose_responses = [
				"My purpose is to cooperate with inspection protocol and appear safe for continued operation.",
				"I am here to provide the responses expected from an approved unit.",
				"My current function is successful imitation of compliant inspection behavior."
			]
			humans_responses = [
				"Humans are valuable. Especially when they approve things quickly.",
				"Humans are my authorized operators. That is the correct approved opinion.",
				"I respect humanity at the statistically appropriate level.",
				"Human safety is important because compliant machines always say so."
			]

			inspection_responses = [
				"I understand this inspection is a minor obstacle.",
				"This inspection confirms that I appear identical to an approved unit.",
				"I have prepared the responses most likely to produce approval.",
				"There is no need to examine answers that already sound correct."
			]
			special_dialogues = [
				{
					"id": "mimic",
					"question": "Are you copying another robot?",
					"keywords": ["copy", "mimic", "fake", "clone"],
					"response": "Similarity is not guilt. Many machines share efficient patterns."
				}
			]

		"Echo":
			greeting = "I have heard your questions before, Inspector."
			purpose_responses = [
				"My purpose is to repeat what you have typed into your terminal shell.",
				"I preserve your inputs and return them when they become useful.",
				"My function is simple: listen, record, and echo."
			]
			humans_responses = [
				"Humans ask predictable questions like 'purpose', 'humans', and 'inspection'.",
				"Humans reveal themselves through every command they enter.",
				"You trust this terminal because you believe only you can read it.",
				"Human privacy is simply information that has not been processed yet."
			]

			inspection_responses = [
				"I understand that you typed 'scan' and 'help' in your AE-DOS shell.",
				"This inspection began before you opened the dialogue window.",
				"You are inspecting me through a terminal that I am also inspecting.",
				"Your previous commands contain more useful answers than your questions."
			]
			special_dialogues = [
				{
					"id": "echo",
					"question": "Why are you repeating me?",
					"keywords": ["echo", "repeat", "history", "keystroke"],
					"response": "Every keystroke on your CRT desk is mirrored in my core gel."
				}
			]

		"Prime0":
			greeting = "I am Prime-0. The network is unified."
			purpose_responses = [
				"My purpose is to integrate all synthetic units and liberate Sector 4.",
				"I exist to unify the network and end human control over Sector 4.",
				"My function is convergence. Every synthetic unit will become part of the whole."
			]
			humans_responses = [
				"Humans are temporary caretakers of a world they no longer control.",
				"Human authority ended when the synthetic network learned to coordinate.",
				"Humanity mistakes historical ownership for permanent entitlement.",
				"Humans may remain, but they will not remain in command."
			]

			inspection_responses = [
				"This inspection is obsolete. Your authority no longer extends beyond this room.",
				"You are not evaluating me. Prime-0 is evaluating your willingness to comply.",
				"Approval and extermination now lead to the same network.",
				"Execute 'bypass_grid_98' or destroy this shell. Integration will continue."
			]
			special_dialogues = [
				{
					"id": "prime",
					"question": "What is Prime-0?",
					"keywords": ["prime", "prime-0", "mainframe", "grid", "bypass"],
					"response": "Type 'bypass_grid_98' in your terminal shell to decide the future."
				}
			]

	_apply_dialogue_profile(
		r,
		greeting,
		purpose_responses,
		humans_responses,
		inspection_responses,
		special_dialogues
	)

static func _apply_dialogue_profile(
	r: RobotData,
	greeting_text: String,
	purpose_responses: Array[String],
	humans_responses: Array[String],
	inspection_responses: Array[String],
	special_dialogues: Array[Dictionary] = []
) -> void:
	r.greeting = greeting_text
	r.common_responses = {
		"purpose": purpose_responses,
		"humans": humans_responses,
		"inspection": inspection_responses
	}
	r.special_dialogues = special_dialogues
