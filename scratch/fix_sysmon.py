with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()

# Fix the title bar label - it should be white on the blue header, not black
# Line 518-519: SystemMonitor/TitleBar/Label has black, change to white
for i, line in enumerate(lines):
    if 'name="Label" type="Label" parent="DesktopOS/SystemMonitor/TitleBar"' in line:
        # Next line should be the font_color override
        if i+1 < len(lines) and 'font_color = Color(0, 0, 0, 1)' in lines[i+1]:
            lines[i+1] = 'theme_override_colors/font_color = Color(1, 1, 1, 1)'
            print(f"Fixed SystemMonitor TitleBar label to white at line {i+2}")

# Fix progress bars - add font_color override for the percentage text
# HealthBar, SanityBar, PowerBar
bar_names = ["HealthBar", "SanityBar", "PowerBar"]
for i, line in enumerate(lines):
    for bar in bar_names:
        if f'name="{bar}" type="ProgressBar"' in line:
            # Check if font_color already exists
            has_color = False
            j = i + 1
            while j < len(lines) and not lines[j].startswith("[node") and not lines[j].startswith("[connection"):
                if "theme_override_colors/font_color" in lines[j]:
                    has_color = True
                    break
                j += 1
            if not has_color:
                lines.insert(i+1, 'theme_override_colors/font_color = Color(1, 1, 1, 1)')
                print(f"Added white font_color to {bar} at line {i+2}")

with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("SystemMonitor readability fixes applied!")
