import os

targets = ["aparatus", "apperatus", "appuratus"]
found_any = False

for root, dirs, files in os.walk("."):
    # Skip .git and .godot
    if ".git" in root or ".godot" in root:
        continue
    for file in files:
        if file.endswith((".gd", ".tscn", ".md", ".txt", ".cfg", ".gdshader")):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    for t in targets:
                        if t in content.lower():
                            print(f"Found '{t}' in {path}")
                            found_any = True
            except Exception as e:
                print(f"Error reading {path}: {e}")

if not found_any:
    print("No misspelled instances of 'Apparatus' found.")
