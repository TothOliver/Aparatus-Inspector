with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

in_node = False
for i, line in enumerate(lines):
    if 'name="ApproveInfo"' in line or 'name="ExterminateInfo"' in line:
        print(f"Line {i+1}: {line}")
        for k in range(1, 15):
            if i+k < len(lines):
                print(f"  {lines[i+k]}")
