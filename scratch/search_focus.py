import os
import re

scripts_dir = r"c:\Users\Barnen\Desktop\awtbg\Scripts"
for root, dirs, files in os.walk(scripts_dir):
    for file in files:
        if file.endswith(".gd"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            # Find lines containing focus
            lines = content.splitlines()
            for i, line in enumerate(lines):
                if "focus" in line.lower() or "grab" in line.lower() or "submit" in line.lower():
                    print(f"{file}:{i+1}: {line.strip()}")
