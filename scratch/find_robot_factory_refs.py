import os

search_dir = r"c:\Users\Barnen\Desktop\awtbg"
query = "RobotFactory"

for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith((".gd", ".tscn", ".gdshader")):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    for i, line in enumerate(f):
                        if query.lower() in line.lower():
                            print(f"{file}:{i+1}: {line.strip()}")
            except Exception as e:
                pass
