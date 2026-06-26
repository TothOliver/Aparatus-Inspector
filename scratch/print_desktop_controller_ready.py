with open("Scripts/desktop_controller.gd", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i in range(30, 180):
    if i < len(lines):
        print(f"{i+1}: {lines[i]}", end="")
