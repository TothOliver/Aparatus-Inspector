with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "CloseButton" in line or 'name="CloseButton"' in line or "connection" in line:
        if "CloseButton" in line:
            print(f"Line {i+1}: {line.strip()}")
            # Print nearby lines to see context
            for k in range(max(0, i-2), min(len(lines), i+8)):
                print(f"  {k+1}: {lines[k].rstrip()}")
