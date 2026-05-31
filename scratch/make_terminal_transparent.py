with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Make the terminal input field stylebox empty (transparent)
old_style = '[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_terminal_bg"]'
new_style = '[sub_resource type="StyleBoxEmpty" id="StyleBoxFlat_terminal_bg"]'
content = content.replace(old_style, new_style)

# Adjust OutputLog offset_bottom to line up perfectly with InputField
old_offset = """[node name="OutputLog" type="RichTextLabel" parent="TerminalWindow/TerminalBody"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 8.0
offset_top = 8.0
offset_right = -8.0
offset_bottom = -40.0"""

new_offset = """[node name="OutputLog" type="RichTextLabel" parent="TerminalWindow/TerminalBody"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 8.0
offset_top = 8.0
offset_right = -8.0
offset_bottom = -32.0"""

content = content.replace(old_offset, new_offset)

with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write(content)

print("Terminal styling adjusted to match real CMD interface!")
