import os

menu_nodes = ["MenuBar", "MenuFile", "MenuDiag", "MenuSystem", "MenuHelp", "MenuDivider"]
found_refs = []

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
                for idx, line in enumerate(content.splitlines()):
                    for node in menu_nodes:
                        if node in line:
                            found_refs.append((path, idx + 1, line))
            except Exception as e:
                pass

print(f"Total script references found: {len(found_refs)}")
for path, line_no, line in found_refs:
    print(f"{path}:{line_no}: {line}")
