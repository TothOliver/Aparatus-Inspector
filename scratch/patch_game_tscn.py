import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Insert ext_resources
ext_insert = '[ext_resource type="Script" path="res://Scripts/health_bar_counter.gd" id="HealthBar_Script"]\n[ext_resource type="Texture2D" path="res://Sprites/icon_error_strike.png" id="Icon_ErrorStrike"]\n'
content = content.replace('[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Inner_Frame.tres" id="StyleBox_Inner_Frame"]', '[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Inner_Frame.tres" id="StyleBox_Inner_Frame"]\n' + ext_insert)

# 2. Replace HealthLabel text and HealthBar node definition
target_block = """[node name="HealthLabel" type="Label" parent="DesktopOS/SystemMonitor/Health" unique_id=1207754543]
layout_mode = 0
offset_left = 15.0
offset_top = 45.0
offset_right = 195.0
offset_bottom = 70.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 14
text = "Security Health:"

[node name="HealthBar" type="ProgressBar" parent="DesktopOS/SystemMonitor/Health" unique_id=1602687783]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 70.0
offset_right = 195.0
offset_bottom = 95.0
theme_override_colors/font_color = Color(1, 1, 1, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_styles/background = ExtResource("StyleBox_Inner_Frame")
theme_override_styles/fill = SubResource("StyleBoxFlat_fgofq")"""

replacement_block = """[node name="HealthLabel" type="Label" parent="DesktopOS/SystemMonitor/Health" unique_id=1207754543]
layout_mode = 0
offset_left = 15.0
offset_top = 45.0
offset_right = 195.0
offset_bottom = 70.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 14
text = "Security Breaches:"

[node name="HealthBar" type="HBoxContainer" parent="DesktopOS/SystemMonitor/Health" unique_id=1602687783]
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
vertical_alignment = 1"""

if target_block in content:
    content = content.replace(target_block, replacement_block)
    print("Successfully replaced HealthBar block in Scenes/Game.tscn")
else:
    print("Target block not found!")

with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write(content)
