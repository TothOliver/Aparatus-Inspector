with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

print("Searching for menu texts in current...")
lines = content.splitlines()
for i, line in enumerate(lines):
    if any(keyword in line for keyword in ["File", "Diagnostic", "System", "Help", "MenuBar", "MenuDivider"]):
        print(f"L{i+1}: {line}")
