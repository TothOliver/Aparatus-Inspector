import re

# 1. Update death_scene.tscn
tscn_path = "Scenes/death_scene.tscn"
with open(tscn_path, 'r', encoding='utf-8') as f:
    tscn = f.read()

# Check if CRT_Shader is already there
if "CRT_Shader" not in tscn:
    lines = tscn.splitlines()
    
    # Find the insertion point for ext_resource (after the first line or after other ext_resources)
    insert_ext_idx = -1
    for idx, line in enumerate(lines):
        if line.startswith("[ext_resource "):
            insert_ext_idx = idx + 1
    if insert_ext_idx == -1:
        insert_ext_idx = 1
        
    lines.insert(insert_ext_idx, '[ext_resource type="Shader" uid="uid://crt_shader_uid" path="res://crt_filter.gdshader" id="CRT_Shader"]')
    
    # Find the insertion point for sub_resource (before node name="Control")
    insert_sub_idx = -1
    for idx, line in enumerate(lines):
        if line.startswith('[node name="Control"'):
            insert_sub_idx = idx
            break
            
    subresource_text = """[sub_resource type="ShaderMaterial" id="ShaderMaterial_crt"]
shader = ExtResource("CRT_Shader")
shader_parameter/scanline_count = 320.0
shader_parameter/scanline_intensity = 0.08
shader_parameter/curvature = 0.025
shader_parameter/vignette_intensity = 0.08
shader_parameter/grr_intensity = 0.03
shader_parameter/aberration = 0.001
"""
    # Insert sub_resource (we add an extra newline for neatness)
    lines.insert(insert_sub_idx, subresource_text)
    
    # Find insertion point for CRTOverlay node (before the first connection line or at the very end)
    insert_node_idx = -1
    for idx, line in enumerate(lines):
        if line.startswith("[connection "):
            insert_node_idx = idx
            break
    if insert_node_idx == -1:
        insert_node_idx = len(lines)
        
    node_text = """[node name="CRTOverlay" type="ColorRect" parent="."]
unique_name_in_owner = true
material = SubResource("ShaderMaterial_crt")
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
"""
    # Insert node
    lines.insert(insert_node_idx, node_text)
    
    new_tscn = "\n".join(lines) + "\n"
    with open(tscn_path, 'w', encoding='utf-8') as f:
        f.write(new_tscn)
    print("Successfully added CRTOverlay to death_scene.tscn!")
else:
    print("CRTOverlay already exists in death_scene.tscn.")

# 2. Update deathScene.gd to toggle visibility inside _ready()
gd_path = "Scripts/deathScene.gd"
with open(gd_path, 'r', encoding='utf-8') as f:
    gd = f.read()

if "crt_effect_enabled" not in gd:
    # We will insert it inside _ready()
    # Let's find _ready() func
    lines = gd.splitlines()
    ready_idx = -1
    for idx, line in enumerate(lines):
        if "func _ready():" in line:
            ready_idx = idx
            break
            
    if ready_idx != -1:
        # Insert inside _ready (with proper indentation)
        lines.insert(ready_idx + 1, "\tif has_node(\"CRTOverlay\"):")
        lines.insert(ready_idx + 2, "\t\t$CRTOverlay.visible = GameStats.crt_effect_enabled")
        
        new_gd = "\n".join(lines) + "\n"
        with open(gd_path, 'w', encoding='utf-8') as f:
            f.write(new_gd)
        print("Successfully updated deathScene.gd to respect crt settings!")
    else:
        print("Error: Could not find _ready() in deathScene.gd.")
else:
    print("deathScene.gd already respects crt settings.")
