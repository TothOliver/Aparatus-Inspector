import struct
import json

glb_path = r"c:\Users\johan\OneDrive\Desktop\awtbg\assets\Mimic\themimicv2byspade1.glb"

with open(glb_path, "rb") as f:
    magic, version, length = struct.unpack("<I I I", f.read(12))
    chunk_len, chunk_type = struct.unpack("<I I", f.read(8))
    data = json.loads(f.read(chunk_len).decode("utf-8"))

nodes = data.get("nodes", [])
skins = data.get("skins", [])
joints = skins[0].get("joints", []) if skins else []

key_map = {}
for j_idx in joints:
    name = nodes[j_idx].get("name", "")
    # Check for main limbs
    if name.startswith("head_"):
        key_map["head"] = name
    elif name.startswith("spine_2_"):
        key_map["chest"] = name
    elif name.startswith("Bone_502_"):
        key_map["pelvis"] = name
    elif name.startswith("collar_l_"):
        key_map["shoulder_left"] = name
    elif name.startswith("arm_l0_2"):
        key_map["upper_arm_left"] = name
    elif name.startswith("arm_l1_1"):
        key_map["forearm_left"] = name
    elif name.startswith("hand_l_"):
        key_map["hand_left"] = name
    elif name.startswith("collar_r_"):
        key_map["shoulder_right"] = name
    elif name.startswith("arm_r0_3"):
        key_map["upper_arm_right"] = name
    elif name.startswith("arm_r1_3"):
        key_map["forearm_right"] = name
    elif name.startswith("hand_r_"):
        key_map["hand_right"] = name
    elif name.startswith("leg_l0_"):
        key_map["thigh_left"] = name
    elif name.startswith("leg_l1_"):
        key_map["shin_left"] = name
    elif name.startswith("foot_l0_"):
        key_map["foot_left"] = name
    elif name.startswith("leg_r0_"):
        key_map["thigh_right"] = name
    elif name.startswith("leg_r1_"):
        key_map["shin_right"] = name
    elif name.startswith("foot_r0_"):
        key_map["foot_right"] = name

print("MATCHED BONE MAP:")
for k, v in sorted(key_map.items()):
    print(f"  '{k}': '{v}'")
