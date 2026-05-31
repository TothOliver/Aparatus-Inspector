with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    for line in f:
        if "FontFile" in line:
            print(line.strip())
