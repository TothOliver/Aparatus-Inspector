with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Replace TerminalWindow offsets
old_win = """[node name="TerminalWindow" type="NinePatchRect" parent="." unique_id=202610170]
unique_name_in_owner = true
layout_mode = 0
offset_left = 350.0
offset_top = 180.0
offset_right = 950.0
offset_bottom = 630.0"""

new_win = """[node name="TerminalWindow" type="NinePatchRect" parent="." unique_id=202610170]
unique_name_in_owner = true
layout_mode = 0
offset_left = 280.0
offset_top = 180.0
offset_right = 1020.0
offset_bottom = 630.0"""

content = content.replace(old_win, new_win)

# Replace TitleBar offsets
old_tb = """[node name="TitleBar" type="NinePatchRect" parent="TerminalWindow"]
layout_mode = 0
offset_left = 6.0
offset_top = 6.0
offset_right = 594.0"""

new_tb = """[node name="TitleBar" type="NinePatchRect" parent="TerminalWindow"]
layout_mode = 0
offset_left = 6.0
offset_top = 6.0
offset_right = 734.0"""

content = content.replace(old_tb, new_tb)

# Replace CloseButton offsets
old_cb = """[node name="CloseButton" type="Button" parent="TerminalWindow/TitleBar"]
layout_mode = 0
offset_left = 564.0
offset_top = 6.0
offset_right = 582.0"""

new_cb = """[node name="CloseButton" type="Button" parent="TerminalWindow/TitleBar"]
layout_mode = 0
offset_left = 704.0
offset_top = 6.0
offset_right = 722.0"""

content = content.replace(old_cb, new_cb)

# Replace TerminalBody offsets
old_body = """[node name="TerminalBody" type="Control" parent="TerminalWindow"]
layout_mode = 0
offset_left = 10.0
offset_top = 42.0
offset_right = 590.0"""

new_body = """[node name="TerminalBody" type="Control" parent="TerminalWindow"]
layout_mode = 0
offset_left = 10.0
offset_top = 42.0
offset_right = 730.0"""

content = content.replace(old_body, new_body)

with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write(content)

print("Terminal resized to 740px wide in Game.tscn!")
