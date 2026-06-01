with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

search_terms = ["StartMenu", "ShutdownBtn", "ClockPanel", "InspectorTab", "ClockLabel"]
for i, line in enumerate(lines):
    for term in search_terms:
        if term in line:
            print(f"Line {i+1}: {line.strip()}")
