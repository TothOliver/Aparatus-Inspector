with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    for line in f:
        if 'id="2_7lihs"' in line or '2_7lihs' in line:
            if "ext_resource" in line:
                print(line.strip())
