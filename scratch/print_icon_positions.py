with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "Icon" in line and 'type="Button"' in line and 'parent="DesktopOS/DesktopIcons"' in line:
        print(f"Icon: {line.strip()}")
        # print next 10 lines
        for j in range(i+1, i+10):
            print(f"  {lines[j].strip()}")
