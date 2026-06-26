import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Let's search for "Pause" in the tscn
lines = content.splitlines()
for i, line in enumerate(lines):
    if "pause" in line.lower() or "settings" in line.lower():
        print(f"Line {i+1}: {line}")
