import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    tscn = f.read()

lines = tscn.splitlines()
for idx, line in enumerate(lines):
    if 'name="OutputLog"' in line:
        # print node definition and properties
        print(f"L{idx+1}: {line}")
        for i in range(idx+1, idx+20):
            if lines[i].startswith("[node ") or lines[i].strip() == "":
                break
            print(f"  L{i+1}: {lines[i]}")
        break
