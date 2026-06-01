import os

matches = []
for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        if file.endswith(".gd"):
            path = os.path.join(root, file)
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                if "crtoverlay" in content.lower() or "crt_enabled" in content.lower():
                    matches.append(path)
            except Exception as e:
                pass

print(f"Scripts referencing CRT: {matches}")
for path in matches:
    print(f"\n--- {path} ---")
    with open(path, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()
    for idx, line in enumerate(lines):
        if "crtoverlay" in line.lower() or "crt_enabled" in line.lower():
            print(f"  L{idx+1}: {line}")
