import os
import re

search_terms = ["File", "Diagnostic", "System", "Help"]
tscn_matches = []
gd_matches = []

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
                
                # Check for menu bar items
                lines = content.splitlines()
                for idx, line in enumerate(lines):
                    # We are looking for something like File, Diagnostic, System, Help in one place,
                    # or individual menu options, or MenuBar
                    if any(term in line for term in search_terms):
                        if "Aparatus" in line or "inspector" in line.lower() or "menu" in line.lower() or "bar" in line.lower() or "button" in line.lower():
                            if file.endswith(".tscn"):
                                tscn_matches.append((path, idx + 1, line))
                            else:
                                gd_matches.append((path, idx + 1, line))
            except Exception as e:
                pass

print("TSCN Matches:")
for path, line_no, content in tscn_matches[:50]:
    print(f"{path}:{line_no}: {content}")

print("\nGD Matches:")
for path, line_no, content in gd_matches[:50]:
    print(f"{path}:{line_no}: {content}")
