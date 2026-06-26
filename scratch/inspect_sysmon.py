with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

in_sysmon = False
count = 0
for i, line in enumerate(lines):
    if 'name="SystemMonitor"' in line:
        in_sysmon = True
    if in_sysmon:
        print(f"{i+1}: {line.rstrip()}")
        count += 1
        if count > 120:
            break
