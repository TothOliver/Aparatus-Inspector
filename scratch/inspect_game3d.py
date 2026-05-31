with open("Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if 'Viewport' in line or 'SubViewport' in line or 'screen' in line or 'Screen' in line:
        print(f"Line {i+1}: {line.strip()}")
