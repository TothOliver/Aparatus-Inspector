with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "RobotFactory" in line:
        print(f"Line {i}: {line.strip()}")
        # print a few surrounding lines
        for j in range(max(0, i-5), min(len(lines), i+15)):
            print(f"  {j}: {lines[j].strip()}")
