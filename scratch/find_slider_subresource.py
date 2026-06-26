import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()

matches = list(re.finditer(r'\[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_slider"\]', content))
if matches:
    start_idx = matches[0].start()
    lines = content[start_idx:].splitlines()
    print("Around StyleBoxTexture_slider:")
    for idx, line in enumerate(lines[:25]):
        print(f"{idx+1}: {line}")
else:
    print("StyleBoxTexture_slider not found")
