import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()

matches = list(re.finditer(r'\[node name="SettingsWindow"', content))
if matches:
    start_idx = matches[0].start()
    lines = content[start_idx:].splitlines()
    print("SettingsWindow part 2:")
    for idx, line in enumerate(lines[120:200]):
        print(f"{idx+121}: {line}")
