import re

scene_path = "Scenes/Game.tscn"

with open(scene_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Let's write a robust replacement function or use re.sub with state.
# We will match the specific node headers and replace offset_left inside them.

replacements = [
    # 1. NameLabel
    (
        r'(\[node name="NameLabel" type="Label" parent="AparatusInspectorWindow/Model/NamePanel" unique_id=2063255729\]\n(?:[^\n\[]*\n)*)offset_left = 30.0',
        r'\1offset_left = 35.0'
    ),
    # 2. ModelLabel
    (
        r'(\[node name="ModelLabel" type="Label" parent="AparatusInspectorWindow/Model/ModelPanel" unique_id=303726268\]\n(?:[^\n\[]*\n)*)offset_left = 45.0',
        r'\1offset_left = 55.0'
    ),
    # 3. StatusLabel
    (
        r'(\[node name="StatusLabel" type="Label" parent="AparatusInspectorWindow/Model/StatusPanel" unique_id=958371121\]\n(?:[^\n\[]*\n)*)offset_left = 50.0',
        r'\1offset_left = 65.0'
    ),
    # 4. ManuLabel
    (
        r'(\[node name="ManuLabel" type="Label" parent="AparatusInspectorWindow/Model/ManuPanel" unique_id=1969003573\]\n(?:[^\n\[]*\n)*)offset_left = 48.0',
        r'\1offset_left = 55.0'
    )
]

modified = content
for pattern, replacement in replacements:
    modified, count = re.subn(pattern, replacement, modified)
    print(f"Applied replacement (pattern: {pattern[:60]}...), count: {count}")

with open(scene_path, 'w', encoding='utf-8') as f:
    f.write(modified)

print("Game.tscn successfully updated!")
