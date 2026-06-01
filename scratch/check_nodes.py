import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    tscn = f.read()

lines = tscn.splitlines()
in_inspector = False
node_info = []

for i, line in enumerate(lines):
    if line.startswith("[node "):
        name_match = re.search(r'name="([^"]+)"', line)
        parent_match = re.search(r'parent="([^"]+)"', line)
        if name_match:
            name = name_match.group(1)
            parent = parent_match.group(1) if parent_match else ""
            if name == "AparatusInspectorWindow" or parent.startswith("AparatusInspectorWindow") or "AparatusInspectorWindow" in parent:
                node_info.append((i, line))
                in_inspector = True
            else:
                in_inspector = False
    elif in_inspector:
        node_info.append((i, "  " + line))

# Print line numbers and content for lines between 950 and 1250
for i in range(945, 1250):
    if i < len(lines):
        print(f"L{i+1}: {lines[i]}")
