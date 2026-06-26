with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

in_window = False
node_name = ""
props = []

for i, line in enumerate(lines):
    if '[node name="NotepadWindow"' in line:
        in_window = True
        node_name = "NotepadWindow"
        props = []
        continue
    
    if in_window:
        if line.startswith('[node '):
            if 'NotepadWindow' in line:
                if props:
                    print(f"Node: {node_name}")
                    for p in props:
                        print(f"  {p}")
                node_name = line.split('name="')[1].split('"')[0]
                props = []
            else:
                in_window = False
                continue
        else:
            if any(term in line for term in ['texture =', 'theme_override_styles/', 'color =', 'theme_override_colors/', 'theme_override_fonts/']):
                props.append(line.strip())

if in_window and props:
    print(f"Node: {node_name}")
    for p in props:
        print(f"  {p}")
