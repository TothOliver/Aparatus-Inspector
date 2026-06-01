import os

search_text = "APPROVE (Pass)"
matches = []

for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        if file.endswith(".tscn") or file.endswith(".gd") or file.endswith(".md"):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                lines = content.splitlines()
                for idx, line in enumerate(lines):
                    if search_text in line:
                        matches.append((path, idx + 1, line))
            except Exception as e:
                pass

print(f"Found {len(matches)} occurrences:")
for path, line_no, content in matches:
    print(f"{path}:{line_no}: {content}")
