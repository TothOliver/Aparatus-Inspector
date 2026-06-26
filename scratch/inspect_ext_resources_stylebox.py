with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for line in lines:
    if 'ext_resource' in line and ('StyleBox' in line or 'tres' in line):
        print(line.strip())
