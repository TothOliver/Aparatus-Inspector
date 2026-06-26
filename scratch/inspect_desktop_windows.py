with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

windows = []
current_node = ""
for line in lines:
    if line.startswith("[node name="):
        current_node = line.strip()
        if "Window" in current_node or "Window" in line:
            windows.append(current_node)

print("Found window nodes in Game.tscn:")
for w in windows:
    print(w)
