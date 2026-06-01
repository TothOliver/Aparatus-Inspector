with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

for i, line in enumerate(lines):
    if line.startswith('[connection '):
        if 'AparatusInspectorWindow' in line:
            print(f"Line {i+1}: {line}")
