import os

matches = []
for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        if file.endswith(".tscn"):
            path = os.path.join(root, file)
            # Skip the main Game.tscn since we already know it's there
            if "Game.tscn" in path and not path.endswith("Game.tscn"):
                continue
            if path.endswith("Scenes\\Game.tscn") or path.endswith("Scenes/Game.tscn"):
                continue
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                if "AparatusInspectorWindow" in content:
                    matches.append(path)
            except Exception as e:
                pass

print(f"Found AparatusInspectorWindow in other scenes: {matches}")
