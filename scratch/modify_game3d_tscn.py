with open("Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()

# 1. Insert new ext_resources
last_ext_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[ext_resource"):
        last_ext_idx = i

new_ext_resources = [
    '[ext_resource type="Texture2D" uid="uid://win_base_uid" path="res://RetroWindowsGUI/Window_Base.png" id="Icon_WindowBase"]',
    '[ext_resource type="Texture2D" uid="uid://win_header_uid" path="res://RetroWindowsGUI/Window_Header.png" id="Icon_WindowHeader"]',
    '[ext_resource type="FontFile" uid="uid://win_bold_font" path="res://RetroWindowsGUI/windows-bold[1].ttf" id="Font_Bold"]',
    '[ext_resource type="Texture2D" uid="uid://exit_btn_uid" path="res://RetroWindowsGUI/ExitButton.png" id="Icon_ExitBtn"]',
    '[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Inner_Frame.tres" id="StyleBox_InnerFrame"]',
    '[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Button_Normal.tres" id="StyleBox_ButtonNormal"]',
    '[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Button_Hover.tres" id="StyleBox_ButtonHover"]',
    '[ext_resource type="StyleBox" path="res://RetroWindowsGUI/StyleBox_Button_Pressed.tres" id="StyleBox_ButtonPressed"]',
    '[ext_resource type="Texture2D" uid="uid://active_toggle_uid" path="res://RetroWindowsGUI/Windows_Toggle_Active.png" id="Icon_ToggleActive"]',
    '[ext_resource type="Texture2D" uid="uid://inactive_toggle_uid" path="res://RetroWindowsGUI/Windows_Toggle_Inactive.png" id="Icon_ToggleInactive"]',
    '[ext_resource type="Texture2D" uid="uid://slider_bg_uid" path="res://RetroWindowsGUI/Windows_Slider_Background.png" id="Icon_SliderBG"]',
    '[ext_resource type="Texture2D" uid="uid://slider_handle_uid" path="res://RetroWindowsGUI/Windows_Slider_Handle.png" id="Icon_SliderHandle"]',
    '[ext_resource type="Script" uid="uid://settings_window_controller_script" path="res://Scripts/settings_window_controller.gd" id="Settings_Controller_Script"]'
]

lines[last_ext_idx+1:last_ext_idx+1] = new_ext_resources

# 2. Insert new sub_resources
last_sub_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[sub_resource"):
        last_sub_idx = i

new_sub_resources = [
    '[sub_resource type="StyleBoxEmpty" id="StyleBoxEmpty_icon"]',
    '',
    '[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_slider"]',
    'texture = ExtResource("Icon_SliderBG")',
    'texture_margin_left = 2.0',
    'texture_margin_top = 1.0',
    'texture_margin_right = 2.0',
    'texture_margin_bottom = 1.0',
    ''
]

lines[last_sub_idx+1:last_sub_idx+1] = new_sub_resources

# Helper function to find a line containing a pattern
def find_line_by_content(pattern, start_from=0):
    for idx in range(start_from, len(lines)):
        if pattern in lines[idx]:
            return idx
    return -1

# 3. Insert PauseMenu block at the end of the HUD hierarchy (just before the next node after Reticle)
# Reticle begins around node declaration of type "ColorRect" and parent "HUD"
reticle_idx = find_line_by_content('[node name="Reticle" type="ColorRect" parent="HUD"')

# Find where the next node starts (i.e. find first "[node" line after reticle_idx)
next_node_idx = -1
for k in range(reticle_idx + 1, len(lines)):
    if lines[k].startswith("[node") or lines[k].startswith("[connection"):
        next_node_idx = k
        break

if next_node_idx == -1:
    next_node_idx = len(lines)

pause_menu_block = [
    '[node name="PauseMenu" type="ColorRect" parent="HUD"]',
    'visible = false',
    'anchors_preset = 15',
    'anchor_right = 1.0',
    'anchor_bottom = 1.0',
    'grow_horizontal = 2',
    'grow_vertical = 2',
    'color = Color(0, 0, 0, 0.4)',
    '',
    '[node name="PauseWindow" type="NinePatchRect" parent="HUD/PauseMenu"]',
    'layout_mode = 1',
    'anchors_preset = 8',
    'anchor_left = 0.5',
    'anchor_top = 0.5',
    'anchor_right = 0.5',
    'anchor_bottom = 0.5',
    'offset_left = -225.0',
    'offset_top = -200.0',
    'offset_right = 225.0',
    'offset_bottom = 200.0',
    'grow_horizontal = 2',
    'grow_vertical = 2',
    'texture = ExtResource("Icon_WindowBase")',
    'patch_margin_left = 12',
    'patch_margin_top = 12',
    'patch_margin_right = 12',
    'patch_margin_bottom = 12',
    '',
    '[node name="TitleBar" type="NinePatchRect" parent="HUD/PauseMenu/PauseWindow"]',
    'layout_mode = 0',
    'offset_left = 6.0',
    'offset_top = 6.0',
    'offset_right = 444.0',
    'offset_bottom = 36.0',
    'mouse_filter = 0',
    'texture = ExtResource("Icon_WindowHeader")',
    'region_rect = Rect2(0, 0, 48, 25)',
    'patch_margin_left = 5',
    'patch_margin_top = 3',
    'patch_margin_right = 5',
    'patch_margin_bottom = 3',
    '',
    '[node name="Title" type="Label" parent="HUD/PauseMenu/PauseWindow/TitleBar"]',
    'layout_mode = 0',
    'offset_left = 8.0',
    'offset_top = 6.0',
    'offset_right = 200.0',
    'offset_bottom = 26.0',
    'theme_override_fonts/font = ExtResource("Font_Bold")',
    'theme_override_font_sizes/font_size = 14',
    'text = "Pause & Settings"',
    '',
    '[node name="CloseButton" type="Button" parent="HUD/PauseMenu/PauseWindow/TitleBar"]',
    'layout_mode = 0',
    'offset_left = 420.0',
    'offset_top = 6.0',
    'offset_right = 438.0',
    'offset_bottom = 24.0',
    'theme_override_styles/normal = ExtResource("StyleBox_ButtonNormal")',
    'theme_override_styles/hover = ExtResource("StyleBox_ButtonHover")',
    'theme_override_styles/pressed = ExtResource("StyleBox_ButtonPressed")',
    'theme_override_styles/focus = SubResource("StyleBoxEmpty_icon")',
    'icon = ExtResource("Icon_ExitBtn")',
    'icon_alignment = 1',
    '',
    '[node name="SettingsBody" type="Control" parent="HUD/PauseMenu/PauseWindow"]',
    'layout_mode = 0',
    'offset_left = 12.0',
    'offset_top = 42.0',
    'offset_right = 438.0',
    'offset_bottom = 388.0',
    'script = ExtResource("Settings_Controller_Script")',
    '',
    '[node name="DisplayGroup" type="Panel" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 10.0',
    'offset_top = 10.0',
    'offset_right = 416.0',
    'offset_bottom = 90.0',
    'theme_override_styles/panel = ExtResource("StyleBox_InnerFrame")',
    '',
    '[node name="DisplayGroupLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 20.0',
    'offset_top = 2.0',
    'offset_right = 120.0',
    'offset_bottom = 18.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("Font_Bold")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Display"',
    '',
    '[node name="CRTCheckbox" type="CheckBox" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 35.0',
    'offset_right = 350.0',
    'offset_bottom = 65.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_hover_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_hover_pressed_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("7_font")',
    'theme_override_font_sizes/font_size = 12',
    'theme_override_icons/checked = ExtResource("Icon_ToggleActive")',
    'theme_override_icons/unchecked = ExtResource("Icon_ToggleInactive")',
    'text = " Enable CRT Screen Filter"',
    '',
    '[node name="AudioGroup" type="Panel" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 10.0',
    'offset_top = 105.0',
    'offset_right = 416.0',
    'offset_bottom = 215.0',
    'theme_override_styles/panel = ExtResource("StyleBox_InnerFrame")',
    '',
    '[node name="AudioGroupLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 20.0',
    'offset_top = 97.0',
    'offset_right = 120.0',
    'offset_bottom = 113.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("Font_Bold")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Audio"',
    '',
    '[node name="VolumeLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 125.0',
    'offset_right = 150.0',
    'offset_bottom = 145.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("7_font")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Master Volume:"',
    '',
    '[node name="VolumeValueLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 160.0',
    'offset_top = 125.0',
    'offset_right = 220.0',
    'offset_bottom = 145.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("Font_Bold")',
    'theme_override_font_sizes/font_size = 12',
    'text = "80%"',
    '',
    '[node name="VolumeSlider" type="HSlider" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 155.0',
    'offset_right = 390.0',
    'offset_bottom = 190.0',
    'theme_override_icons/grabber = ExtResource("Icon_SliderHandle")',
    'theme_override_icons/grabber_highlight = ExtResource("Icon_SliderHandle")',
    'theme_override_styles/slider = SubResource("StyleBoxTexture_slider")',
    'value = 80.0',
    '',
    '[node name="MouseGroup" type="Panel" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 10.0',
    'offset_top = 230.0',
    'offset_right = 416.0',
    'offset_bottom = 340.0',
    'theme_override_styles/panel = ExtResource("StyleBox_InnerFrame")',
    '',
    '[node name="MouseGroupLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 20.0',
    'offset_top = 222.0',
    'offset_right = 150.0',
    'offset_bottom = 238.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("Font_Bold")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Mouse Input"',
    '',
    '[node name="SensitivityLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 250.0',
    'offset_right = 250.0',
    'offset_bottom = 270.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("7_font")',
    'theme_override_font_sizes/font_size = 12',
    'text = "3D Look Sensitivity:"',
    '',
    '[node name="SensitivityValueLabel" type="Label" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 175.0',
    'offset_top = 250.0',
    'offset_right = 250.0',
    'offset_bottom = 270.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("Font_Bold")',
    'theme_override_font_sizes/font_size = 12',
    'text = "0.15"',
    '',
    '[node name="SensitivitySlider" type="HSlider" parent="HUD/PauseMenu/PauseWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 280.0',
    'offset_right = 390.0',
    'offset_bottom = 315.0',
    'theme_override_icons/grabber = ExtResource("Icon_SliderHandle")',
    'theme_override_icons/grabber_highlight = ExtResource("Icon_SliderHandle")',
    'theme_override_styles/slider = SubResource("StyleBoxTexture_slider")',
    'value = 30.0',
    ''
]

lines[next_node_idx:next_node_idx] = pause_menu_block

# 4. Insert connection binding at the end of the file
# Find first connection signal to insert before it, or just append to end
first_conn_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[connection"):
        first_conn_idx = i
        break

connection_line = '[connection signal="pressed" from="HUD/PauseMenu/PauseWindow/TitleBar/CloseButton" to="Player" method="handle_settings_shortcut"]'

if first_conn_idx != -1:
    lines.insert(first_conn_idx, connection_line)
else:
    lines.append(connection_line)

# Save back to file
with open("Scenes/Game3D.tscn", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("Game3D.tscn modified successfully!")
