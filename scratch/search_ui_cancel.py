import os

for root, dirs, files in os.walk("Scripts"):
    for file in files:
        if file.endswith(".gd"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()
            for i, line in enumerate(lines):
                if "ui_cancel" in line:
                    print(f"{file} line {i+1}: {line.strip()}")
