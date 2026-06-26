import os

for root, dirs, files in os.walk("Scripts"):
    for file in files:
        if file.endswith(".gd"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                for idx, line in enumerate(f):
                    line_lower = line.lower()
                    if "enter" in line_lower or "accept" in line_lower or "return" in line_lower or "key_kp_" in line_lower:
                        print(f"{filepath}:{idx+1}: {line.strip()}")
