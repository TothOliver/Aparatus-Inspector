with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for line in lines:
    if 'ext_resource' in line and ('Icon' in line or 'icon' in line or 'Sprite' in line or 'sprite' in line):
        print(line.strip())
