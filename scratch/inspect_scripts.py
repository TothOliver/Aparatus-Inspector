import re

file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Let's search for ExtResource mapping in the scene
ext_resources = re.findall(r'\[ext_resource type="Script" path="([^"]+)" id="([^"]+)"\]', content)
for path, ext_id in ext_resources:
    print(f"ExtResource ID: {ext_id} -> {path}")

print("\n--- NODES WITH SCRIPT ---")
# Find nodes and check if they have a script attribute
nodes = re.findall(r'\[node name="([^"]+)"[^\]]*parent="([^"]*)"(?:[^\n]*\n)*?script = ExtResource\("([^"]+)"\)', content)
for name, parent, ext_id in nodes:
    print(f"Node: {name}, Parent: {parent}, Script ID: {ext_id}")
