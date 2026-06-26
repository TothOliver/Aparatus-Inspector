import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    tscn = f.read()

lines = tscn.splitlines()
in_terminal = False
node_info = []

for idx, line in enumerate(lines):
    if line.startswith("[node "):
        name_match = re.search(r'name="([^"]+)"', line)
        parent_match = re.search(r'parent="([^"]+)"', line)
        if name_match:
            name = name_match.group(1)
            parent = parent_match.group(1) if parent_match else ""
            if "terminal" in name.lower() or "terminal" in parent.lower():
                in_terminal = True
                node_info.append((idx + 1, f"Node: {name} (parent: {parent})"))
            else:
                in_terminal = False
    elif in_terminal:
        if any(keyword in line for keyword in ["font", "theme_override_fonts", "text ="]):
            node_info.append((idx + 1, "  " + line))

for line_no, content in node_info[:100]:
    print(f"L{line_no}: {content}")
