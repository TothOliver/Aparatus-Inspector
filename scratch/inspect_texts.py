import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Find all Button and Label texts in Game3D.tscn
texts = re.findall(r'text\s*=\s*"([^"]+)"', content)
print("Game3D.tscn texts:")
for t in texts:
    print("-", repr(t))
