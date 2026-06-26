import os

for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".gd") or file.endswith(".tscn"):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                if "resume" in content.lower():
                    print(f"Found 'Resume' in: {path}")
            except Exception as e:
                pass
