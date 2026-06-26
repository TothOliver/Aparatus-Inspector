with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

in_terminal = False
count = 0
for i, line in enumerate(lines):
    if 'name="TerminalWindow"' in line and 'parent=' in line:
        in_terminal = True
    if in_terminal:
        print(f"{i+1}: {line.rstrip()}")
        count += 1
        # Stop at next window-level node
        if count > 1 and '[node name=' in line and 'Window' in line and 'parent="DesktopOS"' in line:
            break
        if count > 80:
            break
