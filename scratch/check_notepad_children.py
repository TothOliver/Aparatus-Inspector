with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

found = False
block = []
for line in lines:
    if '[node name="NotepadWindow"' in line:
        found = True
    elif found:
        if line.startswith('['):
            if 'parent="NotepadWindow' in line:
                block.append(line)
            else:
                found = False
        else:
            block.append(line)

print("".join(block))
