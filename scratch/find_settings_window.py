import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()

# Find the definition of SettingsWindow
matches = list(re.finditer(r'\[node name="SettingsWindow"', content))
if matches:
    start_idx = matches[0].start()
    # print surrounding 200 lines
    lines = content[start_idx:].splitlines()
    print("SettingsWindow section:")
    for idx, line in enumerate(lines[:120]):
        print(f"{idx+1}: {line}")
else:
    print("SettingsWindow not found in Game.tscn")
