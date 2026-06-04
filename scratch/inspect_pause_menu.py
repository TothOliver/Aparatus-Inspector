import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Find the PauseMenu node declaration
match = re.search(r'\[node name="PauseMenu".*?\](.*?)(?=\[node|$)', content, re.DOTALL)
if match:
    print("PauseMenu properties:")
    print(match.group(1).strip())
else:
    print("PauseMenu node not found.")
