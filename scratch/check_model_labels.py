import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    tscn = f.read()

lines = tscn.splitlines()
in_model = False
current_node = ""
node_lines = []

for idx, line in enumerate(lines):
    if line.startswith("[node "):
        name_match = re.search(r'name="([^"]+)"', line)
        parent_match = re.search(r'parent="([^"]+)"', line)
        if name_match:
            name = name_match.group(1)
            parent = parent_match.group(1) if parent_match else ""
            if "Model" in name or "Model" in parent:
                in_model = True
                current_node = name
                node_lines.append((idx + 1, f"Node: {name} (parent: {parent})"))
            else:
                in_model = False
    elif in_model:
        if any(keyword in line for keyword in ["offset_", "text =", "theme_override_font_sizes"]):
            node_lines.append((idx + 1, "  " + line))

for line_no, content in node_lines:
    print(f"L{line_no}: {content}")
