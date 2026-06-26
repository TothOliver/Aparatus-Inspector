import re

# Read MainMenu.tscn
with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\MainMenu.tscn', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update load_steps in the first line
# Original: [gd_scene load_steps=14 format=3 uid="uid://dvq7hwhliod3q"]
# We add 6 ext_resources and 2 subresources, so load_steps should be 14 + 8 = 22.
content = re.sub(r'load_steps=\d+', 'load_steps=22', content, count=1)

# 2. Insert new ext_resources after the existing ones
ext_resource_lines = """[ext_resource type="Script" path="res://Scripts/settings_window_controller.gd" id="Settings_Controller_Script"]
[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Inner_Frame.tres" id="StyleBox_Inner_Frame"]
[ext_resource type="Texture2D" path="res://RetroWindowsGUI/Windows_Toggle_Active.png" id="Icon_ToggleActive"]
[ext_resource type="Texture2D" path="res://RetroWindowsGUI/Windows_Toggle_Inactive.png" id="Icon_ToggleInactive"]
[ext_resource type="Texture2D" path="res://RetroWindowsGUI/Windows_Slider_Handle.png" id="Icon_SliderHandle"]
[ext_resource type="Texture2D" path="res://RetroWindowsGUI/Windows_Slider_Background.png" id="Icon_SliderBG"]"""

# Let's find the last [ext_resource... line and insert after it
ext_matches = list(re.finditer(r'\[ext_resource[^\]]*\]', content))
if ext_matches:
    last_ext = ext_matches[-1]
    insert_pos = last_ext.end()
    content = content[:insert_pos] + "\n" + ext_resource_lines + content[insert_pos:]

# 3. Insert new subresources before node declarations
sub_resource_lines = """
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_GroupLabel"]
bg_color = Color(0.83137, 0.81568, 0.78431, 1)
expand_margin_left = 4.0
expand_margin_right = 4.0

[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_slider"]
texture = ExtResource("Icon_SliderBG")
texture_margin_left = 2.0
texture_margin_top = 1.0
texture_margin_right = 2.0
texture_margin_bottom = 1.0
"""

# Find the first [node declaration and insert right before it
node_match = re.search(r'\[node\s', content)
if node_match:
    insert_pos = node_match.start()
    content = content[:insert_pos] + sub_resource_lines + content[insert_pos:]

# 4. Replace the SettingsPopup block
# Start boundary: [node name="SettingsPopup" ... ]
# End boundary: just before [node name="CRTOverlay" ... ]
start_match = re.search(r'\[node\s+name="SettingsPopup"[^\]]*\]', content)
end_match = re.search(r'\[node\s+name="CRTOverlay"[^\]]*\]', content)

if start_match and end_match:
    start_pos = start_match.start()
    end_pos = end_match.start()
    
    new_settings_popup = """[node name="SettingsPopup" type="NinePatchRect" parent="."]
visible = false
layout_mode = 0
offset_left = 415.0
offset_top = 282.0
offset_right = 865.0
offset_bottom = 742.0
texture = ExtResource("8_base")
patch_margin_left = 12
patch_margin_top = 12
patch_margin_right = 12
patch_margin_bottom = 12

[node name="TitleBar" type="NinePatchRect" parent="SettingsPopup"]
layout_mode = 0
offset_left = 6.0
offset_top = 6.0
offset_right = 444.0
offset_bottom = 36.0
mouse_filter = 0
texture = ExtResource("2_koqhg")
region_rect = Rect2(0, 0, 48, 25)
patch_margin_left = 5
patch_margin_top = 3
patch_margin_right = 5
patch_margin_bottom = 3

[node name="Title" type="Label" parent="SettingsPopup/TitleBar"]
layout_mode = 0
offset_left = 8.0
offset_top = 6.0
offset_right = 200.0
offset_bottom = 26.0
theme_override_fonts/font = ExtResource("5_if7li")
theme_override_font_sizes/font_size = 14
text = "System Settings"

[node name="CloseButton" type="Button" parent="SettingsPopup/TitleBar"]
layout_mode = 0
offset_left = 414.0
offset_top = 5.0
offset_right = 434.0
offset_bottom = 25.0
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
theme_override_styles/focus = SubResource("StyleBoxEmpty_icon")
icon = ExtResource("6_rrcx7")
icon_alignment = 1

[node name="SettingsBody" type="Control" parent="SettingsPopup"]
layout_mode = 0
offset_left = 12.0
offset_top = 42.0
offset_right = 438.0
offset_bottom = 448.0
script = ExtResource("Settings_Controller_Script")

[node name="DisplayGroup" type="Panel" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 10.0
offset_top = 10.0
offset_right = 416.0
offset_bottom = 90.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="DisplayGroupLabel" type="Label" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 20.0
offset_top = 2.0
offset_right = 120.0
offset_bottom = 18.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "Display"

[node name="CRTCheckbox" type="CheckBox" parent="SettingsPopup/SettingsBody"]
unique_name_in_owner = true
layout_mode = 0
offset_left = 25.0
offset_top = 35.0
offset_right = 350.0
offset_bottom = 65.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)
theme_override_colors/font_hover_color = Color(0, 0, 0, 1)
theme_override_colors/font_hover_pressed_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
theme_override_icons/checked = ExtResource("Icon_ToggleActive")
theme_override_icons/unchecked = ExtResource("Icon_ToggleInactive")
text = " Enable CRT Screen Filter"

[node name="AudioGroup" type="Panel" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 10.0
offset_top = 105.0
offset_right = 416.0
offset_bottom = 215.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="AudioGroupLabel" type="Label" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 20.0
offset_top = 97.0
offset_right = 120.0
offset_bottom = 113.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "Audio"

[node name="VolumeLabel" type="Label" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 25.0
offset_top = 125.0
offset_right = 150.0
offset_bottom = 145.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
text = "Master Volume:"

[node name="VolumeValueLabel" type="Label" parent="SettingsPopup/SettingsBody"]
unique_name_in_owner = true
layout_mode = 0
offset_left = 160.0
offset_top = 125.0
offset_right = 220.0
offset_bottom = 145.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
text = "80%"

[node name="VolumeSlider" type="HSlider" parent="SettingsPopup/SettingsBody"]
unique_name_in_owner = true
layout_mode = 0
offset_left = 25.0
offset_top = 155.0
offset_right = 390.0
offset_bottom = 190.0
theme_override_icons/grabber = ExtResource("Icon_SliderHandle")
theme_override_icons/grabber_highlight = ExtResource("Icon_SliderHandle")
theme_override_styles/slider = SubResource("StyleBoxTexture_slider")
value = 80.0

[node name="MouseGroup" type="Panel" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 10.0
offset_top = 230.0
offset_right = 416.0
offset_bottom = 340.0
theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")

[node name="MouseGroupLabel" type="Label" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 20.0
offset_top = 222.0
offset_right = 150.0
offset_bottom = 238.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = SubResource("StyleBoxFlat_GroupLabel")
text = "Mouse Input"

[node name="SensitivityLabel" type="Label" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 25.0
offset_top = 250.0
offset_right = 250.0
offset_bottom = 270.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
text = "3D Look Sensitivity:"

[node name="SensitivityValueLabel" type="Label" parent="SettingsPopup/SettingsBody"]
unique_name_in_owner = true
layout_mode = 0
offset_left = 175.0
offset_top = 250.0
offset_right = 250.0
offset_bottom = 270.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("3_cmrfp")
theme_override_font_sizes/font_size = 12
text = "0.15"

[node name="SensitivitySlider" type="HSlider" parent="SettingsPopup/SettingsBody"]
unique_name_in_owner = true
layout_mode = 0
offset_left = 25.0
offset_top = 280.0
offset_right = 390.0
offset_bottom = 315.0
theme_override_icons/grabber = ExtResource("Icon_SliderHandle")
theme_override_icons/grabber_highlight = ExtResource("Icon_SliderHandle")
theme_override_styles/slider = SubResource("StyleBoxTexture_slider")
value = 30.0

[node name="QuitButton" type="Button" parent="SettingsPopup/SettingsBody"]
layout_mode = 0
offset_left = 153.0
offset_top = 360.0
offset_right = 273.0
offset_bottom = 390.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)
theme_override_colors/font_hover_color = Color(0, 0, 0, 1)
theme_override_colors/font_focus_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("5_if7li")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")
theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")
theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")
theme_override_styles/focus = SubResource("StyleBoxEmpty_icon")
text = "Exit Game"

"""
    content = content[:start_pos] + new_settings_popup + content[end_pos:]

with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\MainMenu.tscn', 'w', encoding='utf-8') as f:
    f.write(content)

print("MainMenu.tscn updated successfully.")
