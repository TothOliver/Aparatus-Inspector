with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

current_window = ""
for i, line in enumerate(lines):
    if 'type="NinePatchRect" parent="."' in line:
        current_window = line.strip()
    if 'parent="' in line and '/TitleBar' in line:
        print(f"Window: {current_window}")
        print(f"  Child: {line.strip()}")
        # print offset
        for j in range(i+1, i+6):
            if "offset_" in lines[j]:
                print(f"    {lines[j].strip()}")
