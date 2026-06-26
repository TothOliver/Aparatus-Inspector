import subprocess

# 1. Revert Game.tscn to clean git version
print("Reverting Game.tscn to committed version...")
subprocess.run([r"C:\Program Files\Git\cmd\git.exe", "checkout", "Scenes/Game.tscn"])

scene_path = "Scenes/Game.tscn"

with open(scene_path, 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

# Find start and end index
start_idx = -1
end_idx = -1

for i, line in enumerate(lines):
    if '[node name="AparatusInspectorWindow"' in line:
        start_idx = i
        break

for i, line in enumerate(lines):
    if '[node name="NotepadWindow"' in line:
        end_idx = i
        break

if start_idx == -1 or end_idx == -1:
    print("Error: Could not find node boundaries.")
    exit(1)

print(f"Replacing lines {start_idx + 1} to {end_idx}...")

redesigned_nodes = """[node name="AparatusInspectorWindow" type="NinePatchRect" parent="." unique_id=1911909970]
unique_name_in_owner = true
layout_mode = 0
offset_left = 180.0
offset_top = 40.0
offset_right = 1240.0
offset_bottom = 840.0
texture = ExtResource("2_b2bpf")
patch_margin_left = 12
patch_margin_top = 12
patch_margin_right = 12
patch_margin_bottom = 12
script = ExtResource("11_window")

[node name="TitleBar" type="NinePatchRect" parent="AparatusInspectorWindow"]
layout_mode = 0
offset_left = 6.0
offset_top = 6.0
offset_right = 1054.0
offset_bottom = 36.0
mouse_filter = 0
texture = ExtResource("2_7lihs")
region_rect = Rect2(0, 0, 48, 25)
patch_margin_left = 5
patch_margin_top = 3
patch_margin_right = 5
patch_margin_bottom = 3

[node name="Title" type="Label" parent="AparatusInspectorWindow/TitleBar"]
layout_mode = 0
offset_left = 8.0
offset_top = 6.0
offset_right = 300.0
offset_bottom = 26.0
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 14
text = "Aparatus Inspector AI reviewer"

[node name="CloseButton" type="Button" parent="AparatusInspectorWindow/TitleBar"]
layout_mode = 0
offset_left = 1024.0
offset_top = 6.0
offset_right = 1042.0
offset_bottom = 24.0
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
theme_override_styles/focus = SubResource("StyleBoxEmpty_icon")
icon = ExtResource("7_2irst")
icon_alignment = 1

[node name="Picture" type="Control" parent="AparatusInspectorWindow" unique_id=2014082233]
layout_mode = 0
offset_left = 12.0
offset_top = 45.0
offset_right = 262.0
offset_bottom = 325.0

[node name="RobotArea" type="Panel" parent="AparatusInspectorWindow/Picture" unique_id=1551997195]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="CameraScreenBg" type="ColorRect" parent="AparatusInspectorWindow/Picture/RobotArea"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = 2.0
offset_right = -2.0
offset_bottom = -2.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0, 0, 0, 1)

[node name="RobotTexture" type="TextureRect" parent="AparatusInspectorWindow/Picture" unique_id=275378146]
unique_name_in_owner = true
layout_mode = 0
offset_left = 25.0
offset_top = 15.0
offset_right = 225.0
offset_bottom = 265.0
expand_mode = 1
stretch_mode = 5

[node name="CamLabel" type="Label" parent="AparatusInspectorWindow/Picture"]
layout_mode = 0
offset_left = 10.0
offset_top = 10.0
offset_right = 200.0
offset_bottom = 26.0
theme_override_colors/font_color = Color(0, 0.8, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "CAM 01 - FEED: LIVE"

[node name="DiagLabel" type="Label" parent="AparatusInspectorWindow/Picture"]
layout_mode = 0
offset_left = 10.0
offset_top = 250.0
offset_right = 200.0
offset_bottom = 266.0
theme_override_colors/font_color = Color(0, 0.8, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "TESTING CHAMBER OK"

[node name="AcceptTerminate" type="Control" parent="AparatusInspectorWindow" unique_id=1629775354]
layout_mode = 3
anchors_preset = 0
offset_left = 12.0
offset_top = 340.0
offset_right = 262.0
offset_bottom = 755.0

[node name="ButtonPanel" type="Panel" parent="AparatusInspectorWindow/AcceptTerminate" unique_id=966110224]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="VerdictGroupLabel" type="Label" parent="AparatusInspectorWindow/AcceptTerminate"]
layout_mode = 0
offset_left = 20.0
offset_top = -8.0
offset_right = 140.0
offset_bottom = 8.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "Evaluation Verdict"

[node name="ApproveInfo" type="Label" parent="AparatusInspectorWindow/AcceptTerminate"]
layout_mode = 0
offset_left = 15.0
offset_top = 20.0
offset_right = 235.0
offset_bottom = 85.0
theme_override_colors/font_color = Color(0.3, 0.3, 0.3, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "APPROVE:\\nPass AI core into immediate grid service."
autowrap_mode = 3

[node name="GoodButton" type="Button" parent="AparatusInspectorWindow/AcceptTerminate/ButtonPanel" unique_id=809091503]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 100.0
offset_right = 215.0
offset_bottom = 165.0
theme_override_colors/font_color = Color(0, 0.4, 0, 1)
theme_override_colors/font_hover_color = Color(0, 0.5, 0, 1)
theme_override_colors/font_focus_color = Color(0, 0.4, 0, 1)
theme_override_colors/font_pressed_color = Color(0, 0.3, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 20
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
text = "APPROVE (Pass)"

[node name="ExterminateInfo" type="Label" parent="AparatusInspectorWindow/AcceptTerminate"]
layout_mode = 0
offset_left = 15.0
offset_top = 200.0
offset_right = 235.0
offset_bottom = 265.0
theme_override_colors/font_color = Color(0.3, 0.3, 0.3, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "EXTERMINATE:\\nFlag AI core for immediate disposal."
autowrap_mode = 3

[node name="BadButton" type="Button" parent="AparatusInspectorWindow/AcceptTerminate/ButtonPanel" unique_id=956657047]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 280.0
offset_right = 215.0
offset_bottom = 345.0
theme_override_colors/font_color = Color(0.7, 0, 0, 1)
theme_override_colors/font_hover_color = Color(0.8, 0, 0, 1)
theme_override_colors/font_focus_color = Color(0.7, 0, 0, 1)
theme_override_colors/font_pressed_color = Color(0.6, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 20
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
text = "EXTERMINATE"

[node name="ChatManager" parent="AparatusInspectorWindow" unique_id=1942021245 instance=ExtResource("2_u44n3")]
unique_name_in_owner = true
layout_mode = 1
anchors_preset = 0
anchor_left = 0.0
anchor_top = 0.0
anchor_right = 0.0
anchor_bottom = 0.0
offset_left = 277.0
offset_top = 45.0
offset_right = 792.0
offset_bottom = 505.0
grow_horizontal = 1
grow_vertical = 1

[node name="ChatBorder" type="Panel" parent="AparatusInspectorWindow/ChatManager"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="ChatBg" type="ColorRect" parent="AparatusInspectorWindow/ChatManager/ChatBorder"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = 20.0
offset_right = -2.0
offset_bottom = -2.0
grow_horizontal = 2
grow_vertical = 2
color = Color(1, 1, 1, 1)

[node name="ChatGroupLabel" type="Label" parent="AparatusInspectorWindow/ChatManager"]
layout_mode = 0
offset_left = 20.0
offset_top = -8.0
offset_right = 160.0
offset_bottom = 8.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "Dialogue Interaction Log"

[node name="ScrollContainer" type="ScrollContainer" parent="AparatusInspectorWindow/ChatManager"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 6.0
offset_top = 24.0
offset_right = -6.0
offset_bottom = -6.0
grow_horizontal = 2
grow_vertical = 2
horizontal_scroll_mode = 0
vertical_scroll_mode = 1

[node name="DialoguePanel" type="VBoxContainer" parent="AparatusInspectorWindow/ChatManager/ScrollContainer" unique_id=1209100797]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 3
theme_override_constants/separation = 4

[node name="Option" type="Control" parent="AparatusInspectorWindow" unique_id=442527454]
layout_mode = 3
anchors_preset = 0
offset_left = 277.0
offset_top = 520.0
offset_right = 792.0
offset_bottom = 755.0

[node name="AnswerPanel" type="Panel" parent="AparatusInspectorWindow/Option" unique_id=131471417]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="OptionGroupLabel" type="Label" parent="AparatusInspectorWindow/Option"]
layout_mode = 0
offset_left = 20.0
offset_top = -8.0
offset_right = 160.0
offset_bottom = 8.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "Select Human Response"

[node name="Button1" type="Button" parent="AparatusInspectorWindow/Option" unique_id=1764300952]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 20.0
offset_right = 500.0
offset_bottom = 110.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_colors/font_hover_color = Color(0, 0, 0, 1)
theme_override_colors/font_focus_color = Color(0, 0, 0, 1)
theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 18
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
autowrap_mode = 3

[node name="Button2" type="Button" parent="AparatusInspectorWindow/Option" unique_id=1685185524]
unique_name_in_owner = true
layout_mode = 0
offset_left = 15.0
offset_top = 120.0
offset_right = 500.0
offset_bottom = 210.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_colors/font_hover_color = Color(0, 0, 0, 1)
theme_override_colors/font_focus_color = Color(0, 0, 0, 1)
theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 18
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
autowrap_mode = 3

[node name="Model" type="Control" parent="AparatusInspectorWindow" unique_id=538820585]
layout_mode = 3
anchors_preset = 0
offset_left = 804.0
offset_top = 45.0
offset_right = 1048.0
offset_bottom = 755.0

[node name="InfoPanel" type="Panel" parent="AparatusInspectorWindow/Model" unique_id=356643237]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="DatabaseGroupLabel" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 20.0
offset_top = -8.0
offset_right = 150.0
offset_bottom = 8.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "AI Core Specsheet"

[node name="NameFieldLabel" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 15.0
offset_top = 20.0
offset_right = 150.0
offset_bottom = 36.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "Subject Name:"

[node name="NamePanel" type="Panel" parent="AparatusInspectorWindow/Model" unique_id=722898887]
layout_mode = 0
offset_left = 15.0
offset_top = 40.0
offset_right = 225.0
offset_bottom = 72.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="NameFieldBg" type="ColorRect" parent="AparatusInspectorWindow/Model/NamePanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = 2.0
offset_right = -2.0
offset_bottom = -2.0
grow_horizontal = 2
grow_vertical = 2
color = Color(1, 1, 1, 1)

[node name="StaticNameLabel" type="Label" parent="AparatusInspectorWindow/Model/NamePanel" unique_id=766496088]
layout_mode = 0
offset_left = 8.0
offset_top = 4.0
offset_right = 90.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0.4, 0.4, 0.4, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "ID:"

[node name="NameLabel" type="Label" parent="AparatusInspectorWindow/Model/NamePanel" unique_id=2063255729]
unique_name_in_owner = true
layout_mode = 0
offset_left = 30.0
offset_top = 4.0
offset_right = 200.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 14

[node name="ModelFieldLabel" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 15.0
offset_top = 85.0
offset_right = 180.0
offset_bottom = 101.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "Model Designation:"

[node name="ModelPanel" type="Panel" parent="AparatusInspectorWindow/Model" unique_id=2041964042]
layout_mode = 0
offset_left = 15.0
offset_top = 105.0
offset_right = 225.0
offset_bottom = 137.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="ModelFieldBg" type="ColorRect" parent="AparatusInspectorWindow/Model/ModelPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = 2.0
offset_right = -2.0
offset_bottom = -2.0
grow_horizontal = 2
grow_vertical = 2
color = Color(1, 1, 1, 1)

[node name="StaticModelLabel" type="Label" parent="AparatusInspectorWindow/Model/ModelPanel" unique_id=835369628]
layout_mode = 0
offset_left = 8.0
offset_top = 4.0
offset_right = 90.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0.4, 0.4, 0.4, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "TYPE:"

[node name="ModelLabel" type="Label" parent="AparatusInspectorWindow/Model/ModelPanel" unique_id=303726268]
unique_name_in_owner = true
layout_mode = 0
offset_left = 45.0
offset_top = 4.0
offset_right = 200.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 14

[node name="StatusFieldLabel" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 15.0
offset_top = 150.0
offset_right = 180.0
offset_bottom = 166.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "Chassis Status:"

[node name="StatusPanel" type="Panel" parent="AparatusInspectorWindow/Model" unique_id=1015063183]
layout_mode = 0
offset_left = 15.0
offset_top = 170.0
offset_right = 225.0
offset_bottom = 202.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="StatusFieldBg" type="ColorRect" parent="AparatusInspectorWindow/Model/StatusPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = 2.0
offset_right = -2.0
offset_bottom = -2.0
grow_horizontal = 2
grow_vertical = 2
color = Color(1, 1, 1, 1)

[node name="StaticStatusLabel" type="Label" parent="AparatusInspectorWindow/Model/StatusPanel" unique_id=114314964]
layout_mode = 0
offset_left = 8.0
offset_top = 4.0
offset_right = 90.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0.4, 0.4, 0.4, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "ALIGN:"

[node name="StatusLabel" type="Label" parent="AparatusInspectorWindow/Model/StatusPanel" unique_id=958371121]
unique_name_in_owner = true
layout_mode = 0
offset_left = 50.0
offset_top = 4.0
offset_right = 200.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 14

[node name="ManuFieldLabel" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 15.0
offset_top = 215.0
offset_right = 180.0
offset_bottom = 231.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "Manufacturer Code:"

[node name="ManuPanel" type="Panel" parent="AparatusInspectorWindow/Model" unique_id=566703700]
layout_mode = 0
offset_left = 15.0
offset_top = 235.0
offset_right = 225.0
offset_bottom = 267.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="ManuFieldBg" type="ColorRect" parent="AparatusInspectorWindow/Model/ManuPanel"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 2.0
offset_top = 2.0
offset_right = -2.0
offset_bottom = -2.0
grow_horizontal = 2
grow_vertical = 2
color = Color(1, 1, 1, 1)

[node name="StaticManuLabel" type="Label" parent="AparatusInspectorWindow/Model/ManuPanel" unique_id=1674359586]
layout_mode = 0
offset_left = 8.0
offset_top = 4.0
offset_right = 90.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0.4, 0.4, 0.4, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "CORP:"

[node name="ManuLabel" type="Label" parent="AparatusInspectorWindow/Model/ManuPanel" unique_id=1969003573]
unique_name_in_owner = true
layout_mode = 0
offset_left = 48.0
offset_top = 4.0
offset_right = 200.0
offset_bottom = 28.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 14

[node name="DiagSpecsTitle" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 15.0
offset_top = 290.0
offset_right = 225.0
offset_bottom = 306.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_fgofq")
theme_override_font_sizes/font_size = 12
text = "SYSTEM TELEMETRY:"

[node name="DiagSpecsDetails" type="Label" parent="AparatusInspectorWindow/Model"]
layout_mode = 0
offset_left = 15.0
offset_top = 315.0
offset_right = 225.0
offset_bottom = 600.0
theme_override_colors/font_color = Color(0.2, 0.4, 0.2, 1)
theme_override_fonts/font = ExtResource("9_71axn")
theme_override_font_sizes/font_size = 12
text = "INTEGRITY: NOMINAL\\nEMPATHY: 98.4%\\nCLOCK RATE: 8.87MHz\\nALLOCATED: 64KB RAM\\nOEC LINK: ONLINE\\nTEMP: 37.4C (STABLE)\\nLOGIC STACK: PASS\\nTHREAT INDEX: SCANNED\\nCHAMBER LOCK: SECURE\\n\\n-----------------\\nAPARATUS OS v4.98\\nSYSTEM READY."
autowrap_mode = 3
"""

# Replace in content
new_lines = lines[:start_idx] + redesigned_nodes.splitlines() + lines[end_idx:]

with open(scene_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines) + '\n')

print("AparatusInspectorWindow redesign successfully written to Game.tscn!")
