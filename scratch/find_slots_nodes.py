import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Let's find nodes inside SlotMachine or Slots
lines = content.splitlines()
printing = False
count = 0
for i, line in enumerate(lines):
    if 'name="SlotMachine' in line or 'name="Slots' in line:
        printing = True
        count = 0
    if printing:
        if line.strip().startswith("[node"):
            count += 1
            if count > 40:
                printing = False
        print(f"Line {i+1}: {line}")
