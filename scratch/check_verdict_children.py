with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

found = False
for i, line in enumerate(lines):
    if 'parent="AparatusInspectorWindow/AcceptTerminate"' in line:
        print(f"Line {i}: {line.strip()}")
        for j in range(max(0, i-2), min(len(lines), i+8)):
            print(f"  {j}: {lines[j].strip()}")
