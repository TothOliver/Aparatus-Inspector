with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()

# 1. Insert new ext_resources
last_ext_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[ext_resource"):
        last_ext_idx = i

new_ext_resources = [
    '[ext_resource type="Texture2D" uid="uid://settings_icon_uid" path="res://Sprites/icon_settings.png" id="Icon_Settings"]',
    '[ext_resource type="Texture2D" uid="uid://active_toggle_uid" path="res://RetroWindowsGUI/Windows_Toggle_Active.png" id="Icon_ToggleActive"]',
    '[ext_resource type="Texture2D" uid="uid://inactive_toggle_uid" path="res://RetroWindowsGUI/Windows_Toggle_Inactive.png" id="Icon_ToggleInactive"]',
    '[ext_resource type="Texture2D" uid="uid://slider_bg_uid" path="res://RetroWindowsGUI/Windows_Slider_Background.png" id="Icon_SliderBG"]',
    '[ext_resource type="Texture2D" uid="uid://slider_handle_uid" path="res://RetroWindowsGUI/Windows_Slider_Handle.png" id="Icon_SliderHandle"]',
    '[ext_resource type="Shader" uid="uid://crt_shader_uid" path="res://crt_filter.gdshader" id="CRT_Shader"]',
    '[ext_resource type="Script" uid="uid://settings_window_controller_script" path="res://Scripts/settings_window_controller.gd" id="Settings_Controller_Script"]'
]

lines[last_ext_idx+1:last_ext_idx+1] = new_ext_resources

# 2. Insert new sub_resources
last_sub_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[sub_resource"):
        last_sub_idx = i

new_sub_resources = [
    '[sub_resource type="ShaderMaterial" id="ShaderMaterial_crt"]',
    'shader = ExtResource("CRT_Shader")',
    'shader_parameter/scanline_count = 320.0',
    'shader_parameter/scanline_intensity = 0.22',
    'shader_parameter/curvature = 0.03',
    'shader_parameter/vignette_intensity = 0.15',
    'shader_parameter/grr_intensity = 0.08',
    'shader_parameter/aberration = 0.0015',
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

# Helper functions to locate exact places to insert blocks
def find_line_by_content(pattern, start_from=0):
    for idx in range(start_from, len(lines)):
        if pattern in lines[idx]:
            return idx
    return -1

# 3. Adjust StartMenu offset_top height to accommodate one more button
start_menu_idx = find_line_by_content('[node name="StartMenu" type="NinePatchRect" parent="DesktopOS"]')
if start_menu_idx != -1:
    print(f"Found StartMenu at line {start_menu_idx+1}")
    for k in range(start_menu_idx, start_menu_idx+20):
        if "offset_top = 620.0" in lines[k]:
            lines[k] = "offset_top = 580.0"
            print(f"Updated offset_top to 580.0 at line {k+1}")
            break

# 4. Insert SettingsIcon before SystemMonitor
sys_mon_idx = find_line_by_content('[node name="SystemMonitor" type="NinePatchRect" parent="DesktopOS"]')
settings_icon_block = [
    '[node name="SettingsIcon" type="Button" parent="DesktopOS/DesktopIcons"]',
    'layout_mode = 0',
    'offset_left = 30.0',
    'offset_top = 870.0',
    'offset_right = 140.0',
    'offset_bottom = 960.0',
    'theme_override_styles/normal = SubResource("StyleBoxEmpty_icon")',
    'theme_override_styles/hover = SubResource("StyleBoxFlat_icon_focus")',
    'theme_override_styles/pressed = SubResource("StyleBoxFlat_icon_focus")',
    'theme_override_styles/focus = SubResource("StyleBoxFlat_icon_focus")',
    '',
    '[node name="VBox" type="VBoxContainer" parent="DesktopOS/DesktopIcons/SettingsIcon"]',
    'layout_mode = 1',
    'anchors_preset = 15',
    'anchor_right = 1.0',
    'anchor_bottom = 1.0',
    'grow_horizontal = 2',
    'grow_vertical = 2',
    'mouse_filter = 2',
    'alignment = 1',
    'theme_override_constants/separation = 2',
    '',
    '[node name="Icon" type="TextureRect" parent="DesktopOS/DesktopIcons/SettingsIcon/VBox"]',
    'custom_minimum_size = Vector2(0, 48)',
    'layout_mode = 2',
    'mouse_filter = 2',
    'texture = ExtResource("Icon_Settings")',
    'stretch_mode = 5',
    '',
    '[node name="Label" type="Label" parent="DesktopOS/DesktopIcons/SettingsIcon/VBox"]',
    'layout_mode = 2',
    'theme_override_colors/font_color = Color(1, 1, 1, 1)',
    'theme_override_fonts/font = ExtResource("9_71axn")',
    'theme_override_font_sizes/font_size = 12',
    'text = "System',
    'Settings"',
    'horizontal_alignment = 1',
    'vertical_alignment = 1',
    'theme_override_constants/line_spacing = -4',
    ''
]
lines[sys_mon_idx:sys_mon_idx] = settings_icon_block

# 5. Insert SettingsTab before StartMenu
start_menu_idx = find_line_by_content('[node name="StartMenu" type="NinePatchRect" parent="DesktopOS"]')
settings_tab_block = [
    '[node name="SettingsTab" type="Button" parent="DesktopOS/Taskbar/ActiveTabs"]',
    'unique_name_in_owner = true',
    'custom_minimum_size = Vector2(160, 0)',
    'layout_mode = 2',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_hover_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_focus_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("9_71axn")',
    'theme_override_font_sizes/font_size = 14',
    'text = "Settings"',
    ''
]
lines[start_menu_idx:start_menu_idx] = settings_tab_block

# 6. Insert SettingsBtn before Divider inside ProgramList
divider_idx = find_line_by_content('[node name="Divider" type="ColorRect" parent="DesktopOS/StartMenu/HBox/ProgramList"]')
settings_btn_block = [
    '[node name="SettingsBtn" type="Button" parent="DesktopOS/StartMenu/HBox/ProgramList"]',
    'layout_mode = 2',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_colors/font_hover_color = Color(1, 1, 1, 1)',
    'theme_override_colors/font_focus_color = Color(1, 1, 1, 1)',
    'theme_override_fonts/font = ExtResource("9_71axn")',
    'theme_override_font_sizes/font_size = 12',
    'theme_override_styles/normal = SubResource("StyleBoxEmpty_icon")',
    'theme_override_styles/hover = SubResource("StyleBoxFlat_menu_hover")',
    'theme_override_styles/focus = SubResource("StyleBoxFlat_menu_hover")',
    'text = " System Settings"',
    'icon = ExtResource("Icon_Settings")',
    'alignment = 0',
    ''
]
lines[divider_idx:divider_idx] = settings_btn_block

# 7. Insert SettingsWindow before HackerAlert
alert_idx = find_line_by_content('[node name="HackerAlert" type="NinePatchRect" parent="."')
settings_window_block = [
    '[node name="SettingsWindow" type="NinePatchRect" parent="." unique_id=202610230]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 380.0',
    'offset_top = 150.0',
    'offset_right = 830.0',
    'offset_bottom = 550.0',
    'texture = ExtResource("2_b2bpf")',
    'patch_margin_left = 12',
    'patch_margin_top = 12',
    'patch_margin_right = 12',
    'patch_margin_bottom = 12',
    'script = ExtResource("11_window")',
    '',
    '[node name="TitleBar" type="NinePatchRect" parent="SettingsWindow"]',
    'layout_mode = 0',
    'offset_left = 6.0',
    'offset_top = 6.0',
    'offset_right = 444.0',
    'offset_bottom = 36.0',
    'mouse_filter = 0',
    'texture = ExtResource("2_7lihs")',
    'region_rect = Rect2(0, 0, 48, 25)',
    'patch_margin_left = 5',
    'patch_margin_top = 3',
    'patch_margin_right = 5',
    'patch_margin_bottom = 3',
    '',
    '[node name="Title" type="Label" parent="SettingsWindow/TitleBar"]',
    'layout_mode = 0',
    'offset_left = 8.0',
    'offset_top = 6.0',
    'offset_right = 200.0',
    'offset_bottom = 26.0',
    'theme_override_fonts/font = ExtResource("5_fgofq")',
    'theme_override_font_sizes/font_size = 14',
    'text = "System Settings"',
    '',
    '[node name="CloseButton" type="Button" parent="SettingsWindow/TitleBar"]',
    'layout_mode = 0',
    'offset_left = 420.0',
    'offset_top = 6.0',
    'offset_right = 438.0',
    'offset_bottom = 24.0',
    'theme_override_styles/normal = ExtResource("StyleBox_Button_Normal")',
    'theme_override_styles/hover = ExtResource("StyleBox_Button_Hover")',
    'theme_override_styles/pressed = ExtResource("StyleBox_Button_Pressed")',
    'theme_override_styles/focus = SubResource("StyleBoxEmpty_icon")',
    'icon = ExtResource("7_2irst")',
    'icon_alignment = 1',
    '',
    '[node name="SettingsBody" type="Control" parent="SettingsWindow"]',
    'layout_mode = 0',
    'offset_left = 12.0',
    'offset_top = 42.0',
    'offset_right = 438.0',
    'offset_bottom = 388.0',
    'script = ExtResource("Settings_Controller_Script")',
    '',
    '[node name="DisplayGroup" type="Panel" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 10.0',
    'offset_top = 10.0',
    'offset_right = 416.0',
    'offset_bottom = 90.0',
    'theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")',
    '',
    '[node name="DisplayGroupLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 20.0',
    'offset_top = 2.0',
    'offset_right = 120.0',
    'offset_bottom = 18.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("5_fgofq")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Display"',
    '',
    '[node name="CRTCheckbox" type="CheckBox" parent="SettingsWindow/SettingsBody"]',
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
    'theme_override_fonts/font = ExtResource("9_71axn")',
    'theme_override_font_sizes/font_size = 12',
    'theme_override_icons/checked = ExtResource("Icon_ToggleActive")',
    'theme_override_icons/unchecked = ExtResource("Icon_ToggleInactive")',
    'text = " Enable CRT Screen Filter"',
    '',
    '[node name="AudioGroup" type="Panel" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 10.0',
    'offset_top = 105.0',
    'offset_right = 416.0',
    'offset_bottom = 215.0',
    'theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")',
    '',
    '[node name="AudioGroupLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 20.0',
    'offset_top = 97.0',
    'offset_right = 120.0',
    'offset_bottom = 113.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("5_fgofq")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Audio"',
    '',
    '[node name="VolumeLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 125.0',
    'offset_right = 150.0',
    'offset_bottom = 145.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("9_71axn")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Master Volume:"',
    '',
    '[node name="VolumeValueLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 160.0',
    'offset_top = 125.0',
    'offset_right = 220.0',
    'offset_bottom = 145.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("5_fgofq")',
    'theme_override_font_sizes/font_size = 12',
    'text = "80%"',
    '',
    '[node name="VolumeSlider" type="HSlider" parent="SettingsWindow/SettingsBody"]',
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
    '[node name="MouseGroup" type="Panel" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 10.0',
    'offset_top = 230.0',
    'offset_right = 416.0',
    'offset_bottom = 340.0',
    'theme_override_styles/panel = ExtResource("StyleBox_Inner_Frame")',
    '',
    '[node name="MouseGroupLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 20.0',
    'offset_top = 222.0',
    'offset_right = 150.0',
    'offset_bottom = 238.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("5_fgofq")',
    'theme_override_font_sizes/font_size = 12',
    'text = "Mouse Input"',
    '',
    '[node name="SensitivityLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'layout_mode = 0',
    'offset_left = 25.0',
    'offset_top = 250.0',
    'offset_right = 250.0',
    'offset_bottom = 270.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("9_71axn")',
    'theme_override_font_sizes/font_size = 12',
    'text = "3D Look Sensitivity:"',
    '',
    '[node name="SensitivityValueLabel" type="Label" parent="SettingsWindow/SettingsBody"]',
    'unique_name_in_owner = true',
    'layout_mode = 0',
    'offset_left = 175.0',
    'offset_top = 250.0',
    'offset_right = 250.0',
    'offset_bottom = 270.0',
    'theme_override_colors/font_color = Color(0, 0, 0, 1)',
    'theme_override_fonts/font = ExtResource("5_fgofq")',
    'theme_override_font_sizes/font_size = 12',
    'text = "0.15"',
    '',
    '[node name="SensitivitySlider" type="HSlider" parent="SettingsWindow/SettingsBody"]',
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
lines[alert_idx:alert_idx] = settings_window_block

# 8. Insert CRTOverlay before first connection signal
first_conn_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[connection"):
        first_conn_idx = i
        break

crt_overlay_block = [
    '[node name="CRTOverlay" type="ColorRect" parent="."]',
    'unique_name_in_owner = true',
    'material = SubResource("ShaderMaterial_crt")',
    'layout_mode = 1',
    'anchors_preset = 15',
    'anchor_right = 1.0',
    'anchor_bottom = 1.0',
    'grow_horizontal = 2',
    'grow_vertical = 2',
    'mouse_filter = 2',
    ''
]
lines[first_conn_idx:first_conn_idx] = crt_overlay_block

# 9. Insert connection bindings at the end
# Recalculate first_conn_idx as lines shifted
first_conn_idx = -1
for i, line in enumerate(lines):
    if line.startswith("[connection"):
        first_conn_idx = i
        break

new_connections = [
    '[connection signal="pressed" from="SettingsWindow/TitleBar/CloseButton" to="SettingsWindow" method="close"]',
    '[connection signal="pressed" from="DesktopOS/DesktopIcons/SettingsIcon" to="DesktopOS" method="open_app" binds= ["Settings"]]',
    '[connection signal="pressed" from="DesktopOS/Taskbar/ActiveTabs/SettingsTab" to="DesktopOS" method="toggle_window_from_tab" binds= ["Settings"]]',
    '[connection signal="pressed" from="DesktopOS/StartMenu/HBox/ProgramList/SettingsBtn" to="DesktopOS" method="_on_start_menu_app_selected" binds= ["Settings"]]',
]

lines[first_conn_idx:first_conn_idx] = new_connections

# Save modified Game.tscn
with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("Game.tscn modified successfully!")
