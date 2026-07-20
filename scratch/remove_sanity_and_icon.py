with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Replace HealthBar, SanityLabel, SanityBar and shift PowerLabel/PowerBar
target_block = """[node name="HealthBar" type="HBoxContainer" parent="DesktopOS/SystemMonitor/Health" unique_id=1602687783]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 68.0
offset_right = 195.0
offset_bottom = 100.0
script = ExtResource("HealthBar_Script")

[node name="StrikeIcon" type="TextureRect" parent="DesktopOS/SystemMonitor/Health/HealthBar"]
custom_minimum_size = Vector2(28, 28)
layout_mode = 2
texture = ExtResource("Icon_ErrorStrike")
expand_mode = 1
stretch_mode = 5

[node name="Spacer" type="Control" parent="DesktopOS/SystemMonitor/Health/HealthBar"]
custom_minimum_size = Vector2(6, 28)
layout_mode = 2

[node name="StrikeLabel" type="Label" parent="DesktopOS/SystemMonitor/Health/HealthBar"]
layout_mode = 2
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 18
text = "0 / 4"
vertical_alignment = 1

[node name="SanityLabel" type="Label" parent="DesktopOS/SystemMonitor/Health" unique_id=1531452417]
layout_mode = 0
offset_left = 15.0
offset_top = 115.0
offset_right = 195.0
offset_bottom = 140.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 14
text = "Mental Sanity:"

[node name="SanityBar" type="ProgressBar" parent="DesktopOS/SystemMonitor/Health" unique_id=601489287]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 140.0
offset_right = 195.0
offset_bottom = 165.0
theme_override_colors/font_color = Color(1, 1, 1, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_styles/background = ExtResource("StyleBox_Inner_Frame")
theme_override_styles/fill = SubResource("StyleBoxFlat_71axn")

[node name="PowerLabel" type="Label" parent="DesktopOS/SystemMonitor/Health" unique_id=144926720]
layout_mode = 0
offset_left = 15.0
offset_top = 185.0
offset_right = 195.0
offset_bottom = 210.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 14
text = "Power Grid:"

[node name="PowerBar" type="ProgressBar" parent="DesktopOS/SystemMonitor/Health" unique_id=601489299]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 210.0
offset_right = 195.0
offset_bottom = 235.0"""

replacement_block = """[node name="HealthBar" type="Label" parent="DesktopOS/SystemMonitor/Health" unique_id=1602687783]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 68.0
offset_right = 195.0
offset_bottom = 98.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 18
text = "0 / 4"
script = ExtResource("HealthBar_Script")

[node name="PowerLabel" type="Label" parent="DesktopOS/SystemMonitor/Health" unique_id=144926720]
layout_mode = 0
offset_left = 15.0
offset_top = 115.0
offset_right = 195.0
offset_bottom = 140.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 14
text = "Power Grid:"

[node name="PowerBar" type="ProgressBar" parent="DesktopOS/SystemMonitor/Health" unique_id=601489299]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 140.0
offset_right = 195.0
offset_bottom = 165.0"""

if target_block in content:
    content = content.replace(target_block, replacement_block)
    print("Replaced SysMonitor Health/Sanity nodes successfully")
else:
    print("Target block not found in Game.tscn!")

with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write(content)
