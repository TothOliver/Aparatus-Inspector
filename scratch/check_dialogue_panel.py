with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i in range(1040, min(len(lines), 1080)):
    print(f"{i}: {lines[i].strip()}")
