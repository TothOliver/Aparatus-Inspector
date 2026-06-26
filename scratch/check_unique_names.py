with open('Scenes/Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.read().splitlines()

targets = ['GoodButton', 'BadButton', 'Button1', 'Button2', 'NameLabel', 'ModelLabel', 'StatusLabel', 'ManuLabel', 'RobotTexture']

for t in targets:
    for i, line in enumerate(lines):
        if f'name="{t}"' in line:
            print(f"Line {i+1}: {line}")
            for k in range(1, 4):
                if i+k < len(lines):
                    print(f"  Line {i+k+1}: {lines[i+k]}")
