with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'parent="DesktopOS"' in line or 'parent="DesktopOS/' in line:
        print(f"Line {i+1}: {line.strip()}")
