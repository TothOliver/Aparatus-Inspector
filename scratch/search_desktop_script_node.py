with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "desktop_controller_script" in line or "desktop_controller.gd" in line:
        print(f"Line {i+1}: {line.strip()}")
        # print around it
        start = max(0, i-5)
        end = min(len(lines), i+10)
        for j in range(start, end):
            print(f"  {j+1}: {lines[j].strip()}")
        print()
