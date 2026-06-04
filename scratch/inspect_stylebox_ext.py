import re

with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Let's print all ExtResource declarations containing StyleBox
resources = re.findall(r'\[ext_resource type="([^"]+)" path="([^"]+)" id="([^"]+)"\]', content)
for r_type, r_path, r_id in resources:
    if "stylebox" in r_path.lower():
        print(f"ID: {r_id} -> {r_path}")
