import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Find any nodes with process_mode set in Game3D.tscn
matches = re.finditer(r'\[node name="([^"]+)" type="([^"]+)" parent="([^"]+)".*?\](.*?)(?=\[node|$)', content, re.DOTALL)
print("Nodes with custom properties:")
for m in matches:
    name = m.group(1)
    props = m.group(4)
    if "process_mode" in props:
        print(f"- {name}:")
        print(props.strip())
