with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    for line in f:
        if 'id="9_71axn"' in line or 'id="9_71axn"' in line or '9_71axn' in line:
            if "ext_resource" in line:
                print(line.strip())
