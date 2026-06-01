with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

found = False
block = []
for line in lines:
    if '[node name="AparatusInspectorWindow"' in line:
        found = True
    elif found:
        if line.startswith('['):
            if 'parent="AparatusInspectorWindow"' in line:
                block.append(line)
            elif 'parent="' in line and '/' in line.split('parent="')[1]:
                # Deep child, ignore for direct children list
                pass
            else:
                found = False
        else:
            block.append(line)

print("".join(block))
