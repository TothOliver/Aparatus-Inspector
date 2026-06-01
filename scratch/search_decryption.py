import os

for root, dirs, files in os.walk("Scripts"):
    for file in files:
        if file.endswith(".gd"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "decrypt" in content.lower() or "key" in content.lower():
                print(f"Found in {path}")
