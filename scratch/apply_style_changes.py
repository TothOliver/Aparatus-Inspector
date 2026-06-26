with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()

# Helper function to find a line containing a pattern starting from an index
def find_line(pattern, start=0):
    for idx in range(start, len(lines)):
        if pattern in lines[idx]:
            return idx
    return -1

# 1. Modify ScoreLabel
score_idx = find_line('[node name="ScoreLabel" type="Label" parent="DesktopOS/Taskbar/ActiveTabs" ]') # wait, no, the parent is "SnakeWindow/SnakeBody/HeaderPanel"
# Let's search for exact node name and parent
score_idx = find_line('parent="SnakeWindow/SnakeBody/HeaderPanel"') # This is unique enough!
# Actually, let's find '[node name="ScoreLabel" type="Label" parent="SnakeWindow/SnakeBody/HeaderPanel"]'
score_idx = find_line('[node name="ScoreLabel" type="Label" parent="SnakeWindow/SnakeBody/HeaderPanel"]')

if score_idx != -1:
    print(f"Found ScoreLabel at line {score_idx+1}")
    # Insert color override after the type definition line
    lines.insert(score_idx+1, 'theme_override_colors/font_color = Color(0, 0, 0, 1)')

# 2. Modify StatusLabel
# Recalculate status_idx
status_idx = find_line('[node name="StatusLabel" type="Label" parent="SnakeWindow/SnakeBody/HeaderPanel"]')
if status_idx != -1:
    print(f"Found StatusLabel at line {status_idx+1}")
    lines.insert(status_idx+1, 'theme_override_colors/font_color = Color(0, 0, 0, 1)')

# 3. Modify StartButton
start_btn_idx = find_line('[node name="StartButton" type="Button" parent="SnakeWindow/SnakeBody/HeaderPanel"]')
if start_btn_idx != -1:
    print(f"Found StartButton at line {start_btn_idx+1}")
    # Insert multiple color overrides
    btn_color_overrides = [
        'theme_override_colors/font_color = Color(0, 0, 0, 1)',
        'theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)',
        'theme_override_colors/font_hover_color = Color(0, 0, 0, 1)',
        'theme_override_colors/font_focus_color = Color(0, 0, 0, 1)'
    ]
    lines[start_btn_idx+1:start_btn_idx+1] = btn_color_overrides

# Save modified Game.tscn
with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("Color changes applied to Game.tscn!")
