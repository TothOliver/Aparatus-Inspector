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
    children = n.get("children", [])
    if "root" in name.lower() or "sketchfab" in name.lower() or "mimic" in name.lower() or "armature" in name.lower():
        print(f"Node #{idx}: Name='{name}', Children Indices={children[:10]}")
        for c in children[:10]:
            print(f"   Child #{c}: Name='{nodes[c].get('name')}'")
