import re

scene_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(scene_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Let's find nodes where parent="AparatusInspectorWindow"
# In Godot tscn: parent="AparatusInspectorWindow"
nodes = []
pattern = r'\[node name="([^"]+)" type="([^"]+)" parent="AparatusInspectorWindow"[^\]]*\]'
for match in re.finditer(pattern, content):
    node_header = match.group(0)
    name = match.group(1)
    node_type = match.group(2)
    print(f"Direct Child Node: {name} ({node_type})")
    # print the lines following it until the next node
    start_pos = match.end()
    next_node_match = re.search(r'\[node', content[start_pos:])
    if next_node_match:
        block = content[start_pos:start_pos+next_node_match.start()]
    else:
        block = content[start_pos:]
    print(block.strip())
    print("-" * 50)
