with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_window = False
window_nodes = []

for line in lines:
    if line.startswith('[node name="SettingsWindow"'):
        in_window = True
    elif line.startswith('[node ') and in_window:
        if 'parent="SettingsWindow' not in line:
            in_window = False
            
    if in_window:
        window_nodes.append(line)

with open('c:\\Users\\Barnen\\Desktop\\awtbg\\scratch\\settings_window_nodes.txt', 'w', encoding='utf-8') as f:
    f.writelines(window_nodes)

print(f"Extracted {len(window_nodes)} lines.")
