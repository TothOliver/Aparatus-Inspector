import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()

matches = list(re.finditer(r'\[node name="SettingsWindow"', content))
if matches:
    start_idx = matches[0].start()
    lines = content[start_idx:].splitlines()
    print("SettingsWindow part 3:")
    for idx, line in enumerate(lines[200:230]):
        print(f"{idx+201}: {line}")
