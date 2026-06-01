with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

for j in range(940, 955):
    if j < len(lines):
        print(f"{j+1}: {lines[j]}")
