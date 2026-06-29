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

@export var robotChat: Array[String] = []
@export var humanChat: Array[String] = []

func get_greeting() -> String:
	if not greeting.strip_edges().is_empty():
		return greeting
	if robotChat.size() > 0:
		return robotChat[0]
	return "..."
	
func get_common_response(question_id: String) -> String:
	if common_responses.has(question_id):
		return str(common_responses[question_id])
	return ""
	
func has_common_response(question_id: String) -> bool:
	return common_responses.has(question_id)

func get_special_dialogues() -> Array[Dictionary]:
	return special_dialogues
