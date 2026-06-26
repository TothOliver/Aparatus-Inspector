import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Find any nodes that are children of SettingsWindow
matches = re.finditer(r'\[node name="([^"]+)" type="([^"]+)" parent="([^"]+)".*?\](.*?)(?=\[node|$)', content, re.DOTALL)
print("Nodes under SettingsWindow in Game.tscn:")
for m in matches:
    name = m.group(1)
    type_name = m.group(2)
    parent = m.group(3)
    if "SettingsWindow" in parent:
        print(f"- {name} ({type_name}) under {parent}")
