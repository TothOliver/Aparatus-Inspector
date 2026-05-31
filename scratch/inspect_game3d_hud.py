with open("Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

in_hud = False
for i, line in enumerate(lines):
    if 'parent="HUD"' in line or 'name="HUD"' in line:
        print(f"{i+1}: {line.strip()}")
