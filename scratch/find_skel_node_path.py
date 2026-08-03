import struct
import json

glb_path = r"c:\Users\johan\OneDrive\Desktop\awtbg\assets\Mimic\themimicv2byspade1.glb"

with open(glb_path, "rb") as f:
    magic, version, length = struct.unpack("<I I I", f.read(12))
    chunk_len, chunk_type = struct.unpack("<I I", f.read(8))
    data = json.loads(f.read(chunk_len).decode("utf-8"))

nodes = data.get("nodes", [])

for idx, n in enumerate(nodes):
    name = n.get("name", "")
    # Check if this node is a skeleton / armature or has mesh/skin
    if "skin" in n or "mesh" in n or "Skeleton" in name or "Armature" in name or "root" in name:
        print(f"Node #{idx}: Name='{name}', skin={n.get('skin')}, mesh={n.get('mesh')}, children={n.get('children', [])[:5]}")

scene_root_indices = data.get("scenes", [{}])[0].get("nodes", [])
print(f"Scene root node indices: {scene_root_indices}")
for r in scene_root_indices:
    print(f"  Root Node #{r}: '{nodes[r].get('name')}'")
