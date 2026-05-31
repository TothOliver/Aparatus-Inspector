with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

bar_names = ["HealthBar", "SanityBar", "PowerBar"]
for i, line in enumerate(lines):
    for bar in bar_names:
        if f'name="{bar}" type="ProgressBar"' in line:
            print(f"\nLine {i+1}: {line.strip()}")
            for k in range(i+1, min(i+12, len(lines))):
                if lines[k].startswith("[node"):
                    break
                print(f"  {k+1}: {lines[k].rstrip()}")
