with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

found = False
block = []
count = 0
for line in lines:
    if '[node name="AparatusInspectorWindow"' in line:
        found = True
    if found:
        block.append(line)
        count += 1
        if count >= 80:
            break

print("".join(block))
