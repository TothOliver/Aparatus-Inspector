extends Control
@onready var dialogue_panel = get_node_or_null("ScrollContainer/DialoguePanel") if has_node("ScrollContainer/DialoguePanel") else get_node("DialoguePanel")

var bubble_scene = preload("res://Scenes/ChatBubble.tscn")
var chatCount = -1
	
func add_message(text: String, name: String):
	if text.is_empty():
		return
	if not is_inside_tree() or not dialogue_panel:
		return
	var bubble = bubble_scene.instantiate()
	dialogue_panel.add_child(bubble)
	bubble.set_message(name + ": " + text)
	chatCount += 1
	
	# Auto-scroll to bottom on the next frame
	if not is_inside_tree() or not get_tree():
		return
	await get_tree().process_frame
	if not is_inside_tree() or not dialogue_panel:
		return
	var scroll = dialogue_panel.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func clear_messages():
	chatCount = -1;
	for child in dialogue_panel.get_children():
		child.queue_free()
