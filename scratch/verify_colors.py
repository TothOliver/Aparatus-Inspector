with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

targets = ["MineLabel", "TimerLabel", "FaceButton", "ScoreLabel", "StatusLabel", "StartButton"]
for i, line in enumerate(lines):
    for t in targets:
        if f'name="{t}"' in line:
            print(f"\nLine {i+1}: {line.strip()}")
            for k in range(i+1, min(i+20, len(lines))):
                if lines[k].startswith("[node") or lines[k].startswith("[connection"):
                    break
                print(f"  {k+1}: {lines[k].rstrip()}")
