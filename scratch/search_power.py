import os

scripts_dir = r"c:\Users\Barnen\Desktop\awtbg\Scripts"
for root, dirs, files in os.walk(scripts_dir):
    for file in files:
        if file.endswith(".gd"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
            lines = content.splitlines()
            for i, line in enumerate(lines):
                if "power" in line.lower():
                    print(f"{file}:{i+1}: {line.strip()}")
