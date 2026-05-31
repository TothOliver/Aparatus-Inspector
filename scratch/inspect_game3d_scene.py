import re

file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game3D.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
print("--- GAME3D.TSCN NODES ---")
for line in lines:
    if line.startswith('[node name='):
        print(line.strip())
