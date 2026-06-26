with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\death_scene.tscn', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update Restart button layout
# From:
# [node name="Restart" type="Button" parent="Window" unique_id=1857837205]
# unique_name_in_owner = true
# layout_mode = 0
# offset_left = 90.0
# offset_top = 350.0
# offset_right = 210.0
# offset_bottom = 380.0
# To:
# [node name="Restart" type="Button" parent="Window" unique_id=1857837205]
# unique_name_in_owner = true
# layout_mode = 0
# offset_left = 40.0
# offset_top = 350.0
# offset_right = 150.0
# offset_bottom = 380.0
old_restart = """[node name="Restart" type="Button" parent="Window" unique_id=1857837205]
unique_name_in_owner = true
layout_mode = 0
offset_left = 90.0
offset_top = 350.0
offset_right = 210.0"""

new_restart = """[node name="Restart" type="Button" parent="Window" unique_id=1857837205]
unique_name_in_owner = true
layout_mode = 0
offset_left = 40.0
offset_top = 350.0
offset_right = 150.0"""

content = content.replace(old_restart, new_restart)

# 2. Update Quit button layout
# From:
# [node name="Quit" type="Button" parent="Window" unique_id=776731121]
# unique_name_in_owner = true
# layout_mode = 0
# offset_left = 240.0
# offset_top = 350.0
# offset_right = 360.0
# offset_bottom = 380.0
# To:
# [node name="Quit" type="Button" parent="Window" unique_id=776731121]
# unique_name_in_owner = true
# layout_mode = 0
# offset_left = 300.0
# offset_top = 350.0
# offset_right = 410.0
# offset_bottom = 380.0
old_quit = """[node name="Quit" type="Button" parent="Window" unique_id=776731121]
unique_name_in_owner = true
layout_mode = 0
offset_left = 240.0
offset_top = 350.0
offset_right = 360.0"""

new_quit = """[node name="Quit" type="Button" parent="Window" unique_id=776731121]
unique_name_in_owner = true
layout_mode = 0
offset_left = 300.0
offset_top = 350.0
offset_right = 410.0"""

content = content.replace(old_quit, new_quit)

# 3. Add the MainMenu button right before the Quit button
main_menu_node = """[node name="MainMenu" type="Button" parent="Window"]
layout_mode = 0
offset_left = 170.0
offset_top = 350.0
offset_right = 280.0
offset_bottom = 380.0
theme_override_colors/font_color = Color(0, 0, 0, 1)
theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)
theme_override_colors/font_hover_color = Color(0, 0, 0, 1)
theme_override_colors/font_focus_color = Color(0, 0, 0, 1)
theme_override_fonts/font = ExtResource("7_font")
theme_override_font_sizes/font_size = 12
theme_override_styles/normal = ExtResource("StyleBox_ButtonNormal")
theme_override_styles/pressed = ExtResource("StyleBox_ButtonPressed")
theme_override_styles/hover = ExtResource("StyleBox_ButtonHover")
theme_override_styles/focus = SubResource("StyleBoxEmpty_icon")
text = "Main Menu"

"""

# Insert MainMenu node right before Quit node
quit_node_start = content.find('[node name="Quit"')
if quit_node_start != -1:
    content = content[:quit_node_start] + main_menu_node + content[quit_node_start:]

# Increase load_steps in the first line
# e.g., load_steps=12
import re
load_steps_match = re.search(r'load_steps=(\d+)', content)
if load_steps_match:
    steps = int(load_steps_match.group(1))
    content = content.replace(f'load_steps={steps}', f'load_steps={steps + 1}')

with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\death_scene.tscn', 'w', encoding='utf-8') as f:
    f.write(content)

print("death_scene.tscn updated successfully.")
