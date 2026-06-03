with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn', 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_window = False
window_block = []

for line in lines:
    if line.startswith('[node name="SettingsWindow"'):
        in_window = True
    elif line.startswith('[node ') and in_window:
        # Check if it's a child of SettingsWindow
        # A child has parent="SettingsWindow" or parent="SettingsWindow/...
        if 'parent="SettingsWindow' not in line:
            in_window = False
            
    if in_window:
        window_block.append(line)

print("".join(window_block))
