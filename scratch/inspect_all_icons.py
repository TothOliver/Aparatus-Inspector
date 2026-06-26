with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

current_node = None
for i, line in enumerate(lines):
    if '[node name=' in line and 'parent="DesktopOS/DesktopIcons"' in line:
        current_node = line.strip()
        print(current_node)
        # scan forward for offset
        for j in range(i+1, min(i+15, len(lines))):
            if 'offset_' in lines[j]:
                print("  " + lines[j].strip())
            if '[node name=' in lines[j]:
                break
