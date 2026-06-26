import os

for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        path = os.path.join(root, file)
        try:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            if "diagnostic" in content.lower():
                print(f"Match found in: {path}")
                # Print matching lines
                lines = content.splitlines()
                for idx, line in enumerate(lines):
                    if "diagnostic" in line.lower():
                        print(f"  L{idx+1}: {line}")
        except Exception as e:
            pass
