with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

found = False
block = []
for line in lines:
    if '[node name="TerminalBody"' in line or found:
        if found and line.startswith('['):
            if 'parent="TerminalWindow/TerminalBody' in line:
                block.append(line)
            else:
                found = False
        else:
            found = True
            block.append(line)

print("".join(block))
