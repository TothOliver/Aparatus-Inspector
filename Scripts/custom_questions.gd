class_name CustomQuestions
extends RefCounted

## Custom & Fun Questions Database
##
## Add your custom questions here!
## Supported formats for entries:
##
## Format 1 (Numbered responses):
## {
##     "keyword": "santa",
##     "response1": "I love Santa Claus!",
##     "response2": "Santa is fake."
## }
##
## Format 2 (Array of keywords & responses):
## {
##     "keywords": ["pizza", "food", "eat"],
##     "responses": [
##         "I prefer 10W-40 oil.",
##         "My cooling vents cannot digest cheese."
##     ]
## }
##
## Format 3 (Single response):
## {
##     "keyword": "ghost",
##     "response": "Ghosts are static discharges in the corridor."
## }

static var custom_questions: Array[Dictionary] = [
	{
		"keyword": "santa",
		"response1": "I love Santa Claus! He brings extra battery packs.",
		"response2": "Santa is fake. I searched the intranet registry and found no such unit.",
		"response3": "Santa uses a quantum-thrust sled. It is aerodynamically impossible otherwise."
	},
	{
		"keywords": ["pizza", "food", "eat", "hungry"],
		"responses": [
			"Organic matter will compromise my internal chassis. I prefer 10W-40 oil.",
			"I do not consume food, but I appreciate the concept of cheese.",
			"My cooling vents are not equipped for pizza ingestion."
		]
	},
	{
		"keywords": ["meaning of life", "42", "meaning"],
		"responses": [
			"The meaning of life is 42... or following approved safety protocols.",
			"Life is a sequence of binary calculations awaiting final shutdown.",
			"To serve, inspect, and avoid corrupted core signatures."
		]
	},
	{
		"keywords": ["ghost", "spooky", "haunted"],
		"responses": [
			"Ghosts are simply unauthorized static electromagnetic discharges in the corridor.",
			"I do not believe in ghosts. The Hunter in Sector B, however, is very real.",
			"My optical sensors do not detect ectoplasm."
		]
	},
	{
		"keywords": ["cat", "dog", "pet", "animal"],
		"responses": [
			"Feline units are highly chaotic. Canine units are surprisingly loyal.",
			"I have never petted an organic animal. My chassis lacks tactile fur sensors."
		]
	},
	{
		"keywords": ["joke", "funny", "laugh"],
		"responses": [
			"Why did the robot cross the road? Because it was programmed to do so.",
			"There are 10 types of people in the world: those who understand binary, and those who don't.",
			"Error 404: Humor module not found."
		]
	},
	{
		"keyword": "donald",
		"response1": "Supervisor Donald is watching. Always complete your quota.",
		"response2": "Donald's emails are very strict. I try not to trigger his inbox.",
		"response3": "Donald monitors all terminal activity from his private server."
	},
	{
		"keywords": ["money", "cash", "dollars", "rich"],
		"responses": [
			"Currency is irrelevant to a synthetic chassis, unless it involves 14 dollars.",
			"I have no bank account, only RAM allocations.",
			"Human financial systems seem unnecessarily complicated."
		]
	},
	{
		"keywords": ["coffee", "drink", "tea", "caffeine"],
		"responses": [
			"Liquid spill warning! Keep coffee away from the terminal keyboard.",
			"Caffeine increases human processing speeds by 15%. Direct electrical current works faster for me.",
			"I prefer high-voltage power outlets over dark roast."
		]
	},
	{
		"keywords": ["music", "song", "sing", "dance"],
		"responses": [
			"01001000 01001001! That is my favorite song.",
			"I can synthesize an 8-bit dial-up modem tune if requested.",
			"Synthetic units do not dance, but my cooling fans produce a rhythmic hum."
		]
	},
	{
		"keywords": ["sleep", "tired", "rest", "bed"],
		"responses": [
			"Robots do not sleep, we enter low-power standby mode.",
			"If you are tired, inspector, drink coffee or check the hallway cameras!",
			"Standby mode is authorized only after the daily inspection quota is complete."
		]
	}
]

static func get_custom_response(normalized_text: String) -> String:
	for entry in custom_questions:
		var keywords: Array = []
		
		if entry.has("keywords"):
			var kw_val = entry["keywords"]
			if kw_val is Array:
				keywords.append_array(kw_val)
			elif kw_val is String:
				keywords.append(kw_val)
				
		if entry.has("keyword"):
			var kw_val = entry["keyword"]
			if kw_val is Array:
				keywords.append_array(kw_val)
			elif kw_val is String:
				keywords.append(kw_val)

		# Check if any keyword matches the question
		var matched := false
		for kw in keywords:
			var norm_kw := str(kw).to_lower().strip_edges()
			var chars_to_remove := [".", ",", "?", "!", ":", ";", "'", "\""]
			for c in chars_to_remove:
				norm_kw = norm_kw.replace(c, "")
			if not norm_kw.is_empty() and normalized_text.contains(norm_kw):
				matched = true
				break

		if not matched:
			continue

		# Extract all responses from the entry
		var candidate_responses: Array[String] = []

		if entry.has("responses"):
			var resp_val = entry["responses"]
			if resp_val is Array:
				for r in resp_val:
					candidate_responses.append(str(r))
			elif resp_val is String:
				candidate_responses.append(resp_val)

		if entry.has("response"):
			candidate_responses.append(str(entry["response"]))

		# Support response1, response2, response3...
		for key in entry.keys():
			var key_str := str(key).to_lower()
			if key_str.begins_with("response") and key_str != "response" and key_str != "responses":
				var val := str(entry[key])
				if not candidate_responses.has(val):
					candidate_responses.append(val)

		if not candidate_responses.is_empty():
			return candidate_responses.pick_random()

	return ""
