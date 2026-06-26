import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Let's find all nodes that are children of PauseWindow
nodes = re.findall(r'\[node name="([^"]+)" type="([^"]+)" parent="([^"]+)"', content)
print("Nodes under PauseWindow/PauseMenu:")
for name, type_name, parent in nodes:
    if "Pause" in parent or "Settings" in parent or "HUD" in parent:
        print(f"- {name} ({type_name}) under {parent}")
