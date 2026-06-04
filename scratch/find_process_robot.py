import os

for root, dirs, files in os.walk("."):
    if ".git" in root or ".godot" in root:
        continue
    for file in files:
        if file.endswith(".gd"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
                if "process_robot" in content:
                    for i, line in enumerate(content.split("\n")):
                        if "process_robot" in line:
                            print(f"{path}:{i+1}: {line.strip()}")
