with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game3D.tscn', 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_window = False
window_block = []

for line in lines:
    if line.startswith('[node name="PauseWindow"'):
        in_window = True
    elif line.startswith('[node ') and in_window:
        if 'parent="HUD/PauseMenu/PauseWindow' not in line:
            in_window = False
            
    if in_window:
        window_block.append(line)

print("".join(window_block))
