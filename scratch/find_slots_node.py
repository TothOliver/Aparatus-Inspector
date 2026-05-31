import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()

matches = list(re.finditer(r'\[node name="SlotMachineWindow"', content))
if matches:
    start_idx = matches[0].start()
    lines = content[start_idx:].splitlines()
    print("SlotMachineWindow section:")
    for idx, line in enumerate(lines[:60]):
        print(f"{idx+1}: {line}")
else:
    print("SlotMachineWindow not found")
