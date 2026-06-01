import os

for root, dirs, files in os.walk("."):
    # skip .godot, .git
    if ".godot" in root or ".git" in root:
        continue
    for file in files:
        if file.endswith(".gd") or file.endswith(".tscn"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "dialog" in content.lower() or "popup" in content.lower():
                print(f"Found in {path}")
