with open("Scripts/game3d.gd", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
for idx, line in enumerate(lines):
    if any(keyword in line.lower() for keyword in ["sound", "audio", "play", "click", "sfx"]):
        print(f"L{idx+1}: {line}")
