with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

terminal_start = -1
for i, line in enumerate(lines):
    if 'name="TerminalWindow"' in line:
        terminal_start = i
        break

if terminal_start != -1:
    for j in range(terminal_start, terminal_start + 45):
        if j < len(lines):
            print(f"{j+1}: {lines[j].strip()}")
