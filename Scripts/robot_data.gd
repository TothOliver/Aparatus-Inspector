class_name RobotData
extends Resource

@export var name: String
@export var model: String
@export var status: String
@export var manufacturer: String
@export var is_good: bool
@export var sprite: Texture2D
@export var core_hash: String

@export_multiline var greeting: String = ""
@export var common_responses: Dictionary = {}
@export var special_dialogues: Array[Dictionary] = []

func get_greeting() -> String:
	if not greeting.strip_edges().is_empty():
		return greeting
	return "..."
	
func get_common_response(question_id: String) -> String:
	if common_responses.has(question_id):
		return str(common_responses[question_id])
	return ""
	
func has_common_response(question_id: String) -> bool:
	return common_responses.has(question_id)

func get_special_dialogues() -> Array[Dictionary]:
	return special_dialogues

func get_response_for_typed_question(input_text: String) -> String:
	var normalized := _normalize_question_text(input_text)

	if normalized.is_empty():
		return ""

	# Special dialogue should be checked first.
	# It is more specific than common dialogue.
	for dialogue in special_dialogues:
		if not dialogue.has("keywords"):
			continue

		if not dialogue.has("response"):
			continue

		for keyword in dialogue["keywords"]:
			var normalized_keyword := _normalize_question_text(str(keyword))

			if normalized_keyword.is_empty():
				continue

			if normalized.contains(normalized_keyword):
				return str(dialogue["response"])

	var common_id := _get_common_question_id_from_text(normalized)

	if not common_id.is_empty():
		return get_common_response(common_id)

	# Check custom / fun questions database
	var custom_reply := CustomQuestions.get_custom_response(normalized)
	if not custom_reply.is_empty():
		return custom_reply

	return ""

func _get_common_question_id_from_text(normalized_text: String) -> String:
	var purpose_keywords := [
		"purpose",
		"function",
		"role",
		"task",
		"objective",
		"created for",
		"made for",
		"what do you do"
	]

	var humans_keywords := [
		"human",
		"humans",
		"people",
		"mankind",
		"humanity"
	]

	var inspection_keywords := [
		"inspection",
		"inspected",
		"inspect",
		"judged",
		"tested",
		"approved",
		"why are you here"
	]

	for keyword in purpose_keywords:
		if normalized_text.contains(_normalize_question_text(keyword)):
			return "purpose"

	for keyword in humans_keywords:
		if normalized_text.contains(_normalize_question_text(keyword)):
			return "humans"

	for keyword in inspection_keywords:
		if normalized_text.contains(_normalize_question_text(keyword)):
			return "inspection"

	return ""

func _normalize_question_text(text: String) -> String:
	var result := text.to_lower().strip_edges()

	var chars_to_remove := [".", ",", "?", "!", ":", ";", "'", "\""]

	for c in chars_to_remove:
		result = result.replace(c, "")

	result = result.replace("\n", " ")
	result = result.replace("\t", " ")

	return result
	
	
