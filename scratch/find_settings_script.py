import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()
for line in content.splitlines():
    if "Settings_Controller_Script" in line:
        print(line)
