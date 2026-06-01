with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i in range(1210, min(len(lines), 1225)):
    print(f"{i}: {lines[i].strip()}")
