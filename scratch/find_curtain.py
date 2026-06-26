import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Find all nodes with Curtain in their name or script
nodes = re.findall(r'\[node name="([^"]+)"[^\]]*\]', content)
print("All nodes:")
for node in nodes:
    if "Curtain" in node or "curtain" in node:
        print("Match:", node)

# Also let's print any connections or script assignments involving Curtain
print("\nConnections / Scripts referencing Curtain:")
lines = content.splitlines()
for i, line in enumerate(lines):
    if "Curtain" in line or "curtain" in line:
        print(f"Line {i+1}: {line}")
