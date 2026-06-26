import re

scene_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(scene_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Define the exact DialoguePanel block we want to replace
dialogue_panel_pattern = (
    r'\[node name="DialoguePanel" type="VBoxContainer" parent="AparatusInspectorWindow/ChatManager" unique_id=1209100797\]\n'
    r'layout_mode = 1\n'
    r'anchors_preset = 15\n'
    r'anchor_left = 0.0\n'
    r'anchor_top = 0.0\n'
    r'anchor_right = 1.0\n'
    r'anchor_bottom = 1.0\n'
    r'offset_left = 10.0\n'
    r'offset_top = 40.0\n'
    r'offset_right = -10.0\n'
    r'offset_bottom = -10.0\n'
    r'grow_horizontal = 2\n'
    r'grow_vertical = 2'
)

# The new structure containing the ScrollContainer wrapping DialoguePanel
new_dialogue_panel_block = (
    r'[node name="ScrollContainer" type="ScrollContainer" parent="AparatusInspectorWindow/ChatManager"]\n'
    r'layout_mode = 1\n'
    r'anchors_preset = 15\n'
    r'anchor_right = 1.0\n'
    r'anchor_bottom = 1.0\n'
    r'offset_left = 6.0\n'
    r'offset_top = 39.0\n'
    r'offset_right = -6.0\n'
    r'offset_bottom = -6.0\n'
    r'grow_horizontal = 2\n'
    r'grow_vertical = 2\n'
    r'horizontal_scroll_mode = 0\n'
    r'vertical_scroll_mode = 1\n\n'
    r'[node name="DialoguePanel" type="VBoxContainer" parent="AparatusInspectorWindow/ChatManager/ScrollContainer" unique_id=1209100797]\n'
    r'layout_mode = 2\n'
    r'size_flags_horizontal = 3\n'
    r'size_flags_vertical = 3\n'
    r'theme_override_constants/separation = 4'
)

# Replace in content
modified_content, count = re.subn(dialogue_panel_pattern, new_dialogue_panel_block, content)
print(f"Applied replacement count: {count}")

with open(scene_path, 'w', encoding='utf-8') as f:
    f.write(modified_content)
print("Updated Game.tscn with the scrollable dialogue container wrapper!")
