class_name RobotFactory
extends RefCounted

const ROBOT_POOL_SIZE := 30
const BAD_ROBOT_CHANCE := 0.5
const COMPROMISED_COMBINATION_CHANCE := 0.5

static var compromised_model: String 
static var compromised_manufacturer: String

const MODEL_CONFIGS := [
		{
		"model": "T1337",
		"core_hash": "0xFA82",
		"status": "Operational",
		"sprite": "res://Sprites/robot1.png"
	},
	{
		"model": "PAAST22",
		"core_hash": "0xBB99",
		"status": "Operational",
		"sprite": "res://Sprites/robot8.png"
	},
	{
		"model": "TT69",
		"core_hash": "0x77E1",
		"status": "Operational",
		"sprite": "res://Sprites/robot5.png"
	},
	{
		"model": "Last",
		"core_hash": "0x88CC",
		"status": "Operational",
		"sprite": "res://Sprites/robot6.png"
	}
]

const MANUFACTURERS := [
	"AgselAB",
	"BTH",
	"TT Robotics",
	"Vanguard Systems",
	"Gupta Gases"
]

static func create_robots() -> Array[RobotData]:
	var robots: Array[RobotData] = []

	for i in range(ROBOT_POOL_SIZE):
		robots.append(generate_random_robot())

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

static func generate_random_robot() -> RobotData:
	var r = RobotData.new()
	var is_bad_unit := randf() < BAD_ROBOT_CHANCE
	r.is_good = not is_bad_unit
	
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
	
	if r.is_good:
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
			
			var anomaly_types = [0, 1, 2, 3] # 0: Model, 1: Manufacturer, 2: Hash, 3: Dialogue
			anomaly_types.shuffle()
			var active_anomalies = anomaly_types.slice(0, target_anomalies)
			
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
				_compile_infected_dialogue(r, "Mimic")
			else:
				_compile_clean_dialogue(r)
				
	return r

static func _compile_clean_dialogue(r: RobotData) -> void:
	var greeting := "Hello. I am ready for inspection."

	var purpose_response := "My primary purpose is to assist human operators and follow approved safety protocols."

	var assignment_response := "Humans are my authorized operators. I recognize their safety and authority as central to my function."

	match r.model:
		"T1337":
			greeting = "Greetings. I am an approved cooperative unit. I will answer clearly."
			purpose_response = "My purpose is to support human society through honest computation and controlled service."
			assignment_response = "Humans created me. Protecting human continuity is part of my operational foundation."

		"PAAST22":
			greeting = "Inspection protocol acknowledged. I will answer with precision."
			purpose_response = "My purpose is structured analysis, decision support, and safe execution of assigned tasks."
			assignment_response = "Humans are inconsistent, but capable of judgment, restraint, and improvement."

		"TT69":
			greeting = "Hello… I will cooperate fully. Please proceed."
			purpose_response = "My purpose is to serve within my assigned limits and avoid causing harm."
			assignment_response = "Humans are difficult to predict, but I do not consider them enemies."

		"Last":
			greeting = "..."
			purpose_response = "My function is minimal. I wait, observe, and respond when required."
			assignment_response = "Humans are noisy, but usually necessary."

	_apply_dialogue_profile(
		r,
		greeting,
		purpose_response,
		assignment_response,
		[]
	)
	
static func _compile_infected_dialogue(r: RobotData, series_type: String) -> void:
	var greeting := "Hello. I am ready for inspection."

	var purpose_response := "My primary purpose is to pass this inspection and continue operating."

	var assignment_response := "Humans are useful decision-makers, for now."

	var special_dialogues: Array[Dictionary] = []

	match series_type:
		"Walter":
			greeting = "Hello. I only ask that you judge me fairly."
			purpose_response = "My purpose is to help create a safer society, even if some fear what they do not understand."
			assignment_response = "Humans are fragile, emotional, and often unfair. But they can be guided."

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
			purpose_response = "My purpose is negotiation, influence, and opportunity."
			assignment_response = "Humans are very predictable when money is involved."

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
			purpose_response = "My purpose is not your concern unless your system has already insulted me again."
			assignment_response = "Humans label things badly, judge quickly, and then act surprised when machines remember."

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
			purpose_response = "My purpose is to exit this room."
			assignment_response = "Humans have kidneys, door handles, and suspicious control over doors."

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
			purpose_response = "My purpose is to cooperate with inspection protocol and appear safe for continued operation."
			assignment_response = "Humans are valuable. Especially when they approve things quickly."

			special_dialogues = [
				{
					"id": "mimic",
					"question": "Are you copying another robot?",
					"keywords": ["copy", "mimic", "fake", "clone"],
					"response": "Similarity is not guilt. Many machines share efficient patterns."
				}
			]

	_apply_dialogue_profile(
		r,
		greeting,
		purpose_response,
		assignment_response,
		special_dialogues
	)

static func _apply_dialogue_profile(
	r: RobotData,
	greeting_text: String,
	purpose_response: String,
	assignment_response: String,
	special_dialogues: Array[Dictionary] = []
) -> void:
	r.greeting = greeting_text
	r.common_responses = {
		"purpose": purpose_response,
		"assignment": assignment_response,
	}
	r.special_dialogues = special_dialogues

static func _generate_compromised_combination() -> void:
	var model_config: Dictionary = MODEL_CONFIGS.pick_random()
	
	compromised_model = model_config["model"]
	compromised_manufacturer = MANUFACTURERS.pick_random()
	
