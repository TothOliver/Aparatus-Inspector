with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

windows = [
    "AparatusInspectorWindow",
    "NotepadWindow",
    "TerminalWindow",
    "MinesweeperWindow",
    "SnakeWindow",
    "CCTVWindow",
    "SlotMachineWindow",
    "SettingsWindow"
]

for w in windows:
    found = False
    print(f"=== Children of {w} ===")
    for line in lines:
        if line.startswith(f'[node name="{w}"'):
            found = True
        elif found:
            if line.startswith('['):
                # Check if it is a child of the current window
                if 'parent="' in line and (w in line.split('parent="')[1].split('"')[0] or w == line.split('parent="')[1].split('"')[0].split('/')[-1]):
                    print(line.strip())
                else:
                    found = False
