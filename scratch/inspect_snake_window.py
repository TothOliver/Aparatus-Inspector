with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

in_snake = False
count = 0
for i, line in enumerate(lines):
    if 'node name="SnakeWindow"' in line:
        in_snake = True
    if in_snake:
        if any(w in line for w in ["ScoreLabel", "StatusLabel", "StartButton"]):
            # Print next 15 lines of this node
            print(f"Line {i+1}: {line.strip()}")
            for k in range(i+1, min(i+15, len(lines))):
                print(f"  {lines[k].strip()}")
        count += 1
        if count > 300:
            break
