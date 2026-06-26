import os

terms = ["Diagnostic", "Help", "File"]
matches = []

for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        if file.endswith(".tscn") or file.endswith(".gd"):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                lines = content.splitlines()
                for idx, line in enumerate(lines):
                    if any(t in line for t in terms):
                        matches.append((path, idx + 1, line))
            except Exception as e:
                pass

print(f"Total matches found: {len(matches)}")
for path, line_no, content in matches[:100]:
    print(f"{path}:{line_no}: {content}")
