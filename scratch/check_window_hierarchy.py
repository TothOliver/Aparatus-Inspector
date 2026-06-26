with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

in_window = False
node_info = []

for i, line in enumerate(lines):
    if '[node name="AparatusInspectorWindow"' in line:
        in_window = True
        node_info.append((i+1, line, []))
        continue
    
    if in_window:
        if line.startswith('[node '):
            # Check if this node belongs to AparatusInspectorWindow
            if 'parent="AparatusInspectorWindow' in line:
                node_info.append((i+1, line, []))
            elif 'parent=".' in line or not 'parent=' in line:
                in_window = False
                continue
            else:
                # Sub-child or separate child
                # Let's see if it has AparatusInspectorWindow in its parent path
                if 'AparatusInspectorWindow' in line:
                    node_info.append((i+1, line, []))
                else:
                    in_window = False
                    continue
        else:
            if len(node_info) > 0:
                node_info[-1][2].append(line)

for line_no, header, props in node_info:
    print(f"Line {line_no}: {header}")
    for prop in props:
        if 'offset_' in prop or 'font_size' in prop:
            print(f"  {prop}")
