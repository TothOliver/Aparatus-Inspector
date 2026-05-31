import os

for root, dirs, files in os.walk("Scripts"):
    for file in files:
        if file.endswith(".gd"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                for idx, line in enumerate(f):
                    if "mouse_mode" in line.lower():
                        print(f"{filepath}:{idx+1}: {line.strip()}")
