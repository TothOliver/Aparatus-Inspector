import math

def euler_to_quat(x_deg, y_deg, z_deg):
    rx = math.radians(x_deg)
    ry = math.radians(y_deg)
    rz = math.radians(z_deg)

    cx = math.cos(rx * 0.5)
    sx = math.sin(rx * 0.5)
    cy = math.cos(ry * 0.5)
    sy = math.sin(ry * 0.5)
    cz = math.cos(rz * 0.5)
    sz = math.sin(rz * 0.5)

    w = cx * cy * cz + sx * sy * sz
    x = sx * cy * cz - cx * sy * sz
    y = cx * sy * cz + sx * cy * sz
    z = cx * cy * sz - sx * sy * cz

    return (x, y, z, w)

BONE_MAP = {
	"head": "head_68_244",
	"chest": "spine_2_396_59",
	"pelvis": "Bone_502_12",
	"shoulder_l": "collar_l_213_393",
	"upper_arm_l": "arm_l0_205_412",
	"forearm_l": "arm_l1_190_444",
	"hand_l": "hand_l_178_467",
	"shoulder_r": "collar_r_325_654",
	"upper_arm_r": "arm_r0_317_673",
	"forearm_r": "arm_r1_302_704",
	"hand_r": "hand_r_290_727",
	"thigh_l": "leg_l0_extend_432_918",
	"shin_l": "leg_l1_424_931",
	"foot_l": "foot_l0_529_1052",
	"thigh_r": "leg_r0_extend_462_987",
	"shin_r": "leg_r1_extend_end_439_1032",
	"foot_r": "foot_r0_560_1111"
}

PRESET_POSES = {
	"T-Pose": {},
	"A-Pose": {
		"upper_arm_l": (0, 0, 45),
		"upper_arm_r": (0, 0, -45),
		"forearm_l": (10, 0, 0),
		"forearm_r": (10, 0, 0)
	},
	"Crouch": {
		"pelvis": (-25, 0, 0),
		"thigh_l": (-55, 10, 15),
		"shin_l": (90, 0, 0),
		"foot_l": (-25, 0, 0),
		"thigh_r": (-55, -10, -15),
		"shin_r": (90, 0, 0),
		"foot_r": (-25, 0, 0),
		"chest": (40, 0, 0),
		"head": (-30, 0, 0),
		"upper_arm_l": (45, -20, 35),
		"forearm_l": (80, 0, 0),
		"upper_arm_r": (45, 20, -35),
		"forearm_r": (80, 0, 0)
	},
	"DoorPeek": {
		"chest": (10, 35, 15),
		"head": (-5, 40, -25),
		"upper_arm_l": (70, -40, 25),
		"forearm_l": (85, 0, 0),
		"hand_l": (-20, 0, 0),
		"upper_arm_r": (15, 0, -10),
		"thigh_l": (-10, 0, 0),
		"thigh_r": (10, 0, 0)
	},
	"JumpscareReach": {
		"chest": (-20, 0, 0),
		"head": (25, 0, 0),
		"upper_arm_l": (-75, 25, 20),
		"forearm_l": (30, 0, 0),
		"hand_l": (40, 0, 20),
		"upper_arm_r": (-80, -20, -25),
		"forearm_r": (35, 0, 0),
		"hand_r": (40, 0, -20),
		"thigh_l": (-20, 0, 10),
		"shin_l": (30, 0, 0),
		"thigh_r": (15, 0, -10),
		"shin_r": (10, 0, 0)
	}
}

# Generate subresources text
sub_resources = []
library_dict = {}

anim_idx = 1
for pose_name, pose_data in PRESET_POSES.items():
    sub_id = f"Animation_{anim_idx}"
    anim_idx += 1
    library_dict[pose_name] = sub_id

    tracks_text = []
    track_count = len(pose_data)

    t_i = 0
    for key, euler in pose_data.items():
        bone_name = BONE_MAP[key]
        qx, qy, qz, qw = euler_to_quat(*euler)
        tracks_text.append(f"""tracks/{t_i}/type = "rotation_3d"
tracks/{t_i}/imported = false
tracks/{t_i}/enabled = true
tracks/{t_i}/path = NodePath("themimicv2byspade1/GeneralSkeleton:{bone_name}")
tracks/{t_i}/interp = 1
tracks/{t_i}/loop_wrap = true
tracks/{t_i}/keys = PackedFloat32Array(0, 1, {qx:.5f}, {qy:.5f}, {qz:.5f}, {qw:.5f})""")
        t_i += 1

    tracks_block = "\n".join(tracks_text)
    if tracks_block:
        tracks_block = "\n" + tracks_block

    sub_res = f"""[sub_resource type="Animation" id="{sub_id}"]
resource_name = "{pose_name}"
length = 0.1{tracks_block}"""
    sub_resources.append(sub_res)

# AnimationLibrary subresource
lib_lines = [f'"{name}": SubResource("{sub_id}")' for name, sub_id in library_dict.items()]
lib_block = ",\n".join(lib_lines)
lib_subres = f"""[sub_resource type="AnimationLibrary" id="AnimationLibrary_poses"]
_data = {{
{lib_block}
}}"""

sub_resources.append(lib_subres)

all_subresources_text = "\n\n".join(sub_resources)

tscn_content = f"""[gd_scene load_steps={len(sub_resources) + 3} format=3 uid="uid://bqww0w4gyhtuq"]

[ext_resource type="Script" path="res://Scripts/monster_character.gd" id="1_monster_script"]
[ext_resource type="PackedScene" uid="uid://8kgjlv6gtmcu" path="res://assets/Mimic/themimicv2byspade1.glb" id="2_mimic"]

[sub_resource type="SphereShape3D" id="SphereShape3D_monster"]

{all_subresources_text}

[node name="MonsterCharacter" type="CharacterBody3D" unique_id=119696980]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.08938873, 0)
script = ExtResource("1_monster_script")

[node name="CollisionShape3D" type="CollisionShape3D" parent="." unique_id=1959529780]
shape = SubResource("SphereShape3D_monster")

[node name="themimicv2byspade1" parent="." unique_id=99668532 instance=ExtResource("2_mimic")]
transform = Transform3D(-0.1, 0, 0, 0, 0.1, 0, 0, 0, -0.1, 0, 1.6655425, 0)

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {{
"": SubResource("AnimationLibrary_poses")
}}

[editable path="themimicv2byspade1"]
"""

with open(r"c:\Users\johan\OneDrive\Desktop\awtbg\Scenes\MonsterCharacter.tscn", "w", encoding="utf-8") as f:
    f.write(tscn_content)

print("Updated MonsterCharacter.tscn with 5 Animation subresources and AnimationLibrary!")
