import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'type="Control"' in line or 'desktop_window.gd' in line or 'Window' in line:
        if 'node name=' in line:
            print(f"Line {i+1}: {line.strip()}")
