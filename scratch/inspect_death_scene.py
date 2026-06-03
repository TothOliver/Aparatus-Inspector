with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\death_scene.tscn', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for idx, line in enumerate(lines, 1):
    if line.startswith('[node ') or 'Button' in line:
        print(f"Line {idx}: {line.strip()}")
