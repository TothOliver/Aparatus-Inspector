import struct
import json
import sys

glb_path = r"c:\Users\johan\OneDrive\Desktop\awtbg\assets\Mimic\themimicv2byspade1.glb"

with open(glb_path, "rb") as f:
    magic, version, length = struct.unpack("<I I I", f.read(12))
    assert magic == 0x46546C67, "Not a valid GLB file"
    
    chunk_len, chunk_type = struct.unpack("<I I", f.read(8))
    assert chunk_type == 0x4E4F534A, "First chunk is not JSON"
    
    json_data = f.read(chunk_len).decode("utf-8")
    data = json.loads(json_data)

nodes = data.get("nodes", [])
skins = data.get("skins", [])
animations = data.get("animations", [])

print(f"Total nodes in GLB: {len(nodes)}")
print(f"Total skins: {len(skins)}")
print(f"Total animations: {len(animations)}")

if skins:
    for s_idx, skin in enumerate(skins):
        joints = skin.get("joints", [])
        print(f"\nSkin #{s_idx} '{skin.get('name', '')}' has {len(joints)} joints:")
        for j_idx in joints:
            node = nodes[j_idx]
            parent_id = None
            for p_idx, candidate in enumerate(nodes):
                if j_idx in candidate.get("children", []):
                    parent_id = candidate.get("name", f"Node_{p_idx}")
                    break
            print(f"  Joint [{j_idx}] Node Name: '{node.get('name', '')}' (Parent: {parent_id})")
else:
    print("\nNo skin found! Printing all nodes with children:")
    for idx, node in enumerate(nodes):
        print(f" Node [{idx}] Name: '{node.get('name', '')}', Children: {node.get('children', [])}")
