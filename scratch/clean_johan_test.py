with open('Scenes/JohanTest.tscn', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False

for line in lines:
    if line.startswith('[node name="HunterPhase5"') or line.startswith('[node name="HunterPhase6"') or line.startswith('[node name="HunterPhase7"') or line.startswith('[node name="HunterPhase8"'):
        skip = True
        continue
    if line.startswith('[node name="CollisionShape3D2"') or line.startswith('[node name="AudioStreamPlayer3D2"') or line.startswith('[node name="Sprite3D2"'):
        skip = True
        continue
    if skip and line.startswith('[node '):
        skip = False
    
    if not skip:
        new_lines.append(line)

with open('Scenes/JohanTest.tscn', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("Cleaned JohanTest.tscn! Total lines remaining:", len(new_lines))
