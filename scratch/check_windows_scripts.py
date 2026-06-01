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
    block = []
    for line in lines:
        if line.startswith(f'[node name="{w}"'):
            found = True
            block.append(line)
        elif found:
            if line.startswith('['):
                break
            block.append(line)
    if found:
        print(f"--- Block for {w} ---")
        print("".join(block))
