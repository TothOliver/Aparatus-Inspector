import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()
for line in content.splitlines()[:50]:
    if ".ttf" in line or ".png" in line or "font" in line:
        print(line)
