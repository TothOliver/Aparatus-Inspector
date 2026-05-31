with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

in_node = False
node_name = ""
parent_name = ""
node_type = ""
node_lines = []

for i, line in enumerate(lines):
    if line.startswith("[node"):
        if in_node:
            # Analyze previous node
            has_font_color = any("theme_override_colors/font_" in l for l in node_lines)
            if node_type in ["Label", "Button"] and not has_font_color:
                # ignore close button or tabs that we know are handled in code
                if "CloseButton" not in node_name and "Tab" not in node_name:
                    print(f"Line {start_line}: {node_name} ({node_type}) under {parent_name} lacks font color override")
        in_node = True
        node_lines = []
        start_line = i + 1
        # Extract name, type, parent
        import re
        m_name = re.search(r'name="([^"]+)"', line)
        m_type = re.search(r'type="([^"]+)"', line)
        m_parent = re.search(r'parent="([^"]+)"', line)
        node_name = m_name.group(1) if m_name else ""
        node_type = m_type.group(1) if m_type else ""
        parent_name = m_parent.group(1) if m_parent else ""
    elif in_node:
        node_lines.append(line)
