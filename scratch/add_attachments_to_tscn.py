import os

tscn_content = """[gd_scene load_steps=4 format=3 uid="uid://bqww0w4gyhtuq"]

[ext_resource type="Script" path="res://Scripts/monster_character.gd" id="1_monster_script"]
[ext_resource type="PackedScene" uid="uid://8kgjlv6gtmcu" path="res://assets/Mimic/themimicv2byspade1.glb" id="2_mimic"]

[sub_resource type="SphereShape3D" id="SphereShape3D_monster"]

[node name="MonsterCharacter" type="CharacterBody3D" unique_id=119696980]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.08938873, 0)
script = ExtResource("1_monster_script")

[node name="CollisionShape3D" type="CollisionShape3D" parent="." unique_id=1959529780]
shape = SubResource("SphereShape3D_monster")

[node name="themimicv2byspade1" parent="." unique_id=99668532 instance=ExtResource("2_mimic")]
transform = Transform3D(-0.1, 0, 0, 0, 0.1, 0, 0, 0, -0.1, 0, 1.6655425, 0)

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]

[editable path="themimicv2byspade1"]
"""

with open(r"c:\Users\johan\OneDrive\Desktop\awtbg\Scenes\MonsterCharacter.tscn", "w", encoding="utf-8") as f:
    f.write(tscn_content)

print("Updated MonsterCharacter.tscn")
