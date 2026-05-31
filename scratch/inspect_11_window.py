import re

file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
in_node = False
current_node = ""
for line in lines:
    if line.startswith('[node name='):
        current_node = line
        in_node = True
    elif line.startswith('['):
        in_node = False
    elif in_node and 'script = ExtResource("11_window")' in line:
        print(f"Node matches 11_window: {current_node}")
