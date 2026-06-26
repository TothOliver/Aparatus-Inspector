import os

matches = []
for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        if file.endswith(".tscn"):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                if "crt" in content.lower():
                    matches.append(path)
            except Exception as e:
                pass

print(f"Scenes referencing 'crt': {matches}")

# Let's inspect the exact lines where crt appears in Game.tscn or Game3D.tscn
for path in matches:
    print(f"\n--- References in {path} ---")
    with open(path, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()
    for idx, line in enumerate(lines):
        if "crt" in line.lower() or "shader" in line.lower():
            # print surrounding lines
            start = max(0, idx - 2)
            end = min(len(lines), idx + 5)
            print(f"Lines {start+1}-{end}:")
            for i in range(start, end):
                print(f"  L{i+1}: {lines[i]}")
