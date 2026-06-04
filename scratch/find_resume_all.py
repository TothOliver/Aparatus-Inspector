import os

for root, dirs, files in os.walk("."):
    for file in files:
        path = os.path.join(root, file)
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "resume" in content.lower():
                print(f"Found 'Resume' in: {path}")
        except Exception as e:
            pass
print("Search complete.")
