with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

idx = -1
for i, line in enumerate(lines):
    if 'name="RobotTexture"' in line:
        idx = i
        break

if idx != -1:
    for j in range(idx, min(len(lines), idx + 20)):
        print(f"{j+1}: {lines[j]}")
