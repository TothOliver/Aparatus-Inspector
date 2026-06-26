# Modify Game3D.tscn to add CCTV Camera and Door Light indicator
import re

tscn_path = "Scenes/Game3D.tscn"

with open(tscn_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add SubResources for the Door Light mesh and material
sub_resources = """[sub_resource type="SphereMesh" id="SphereMesh_door_light"]
radius = 0.04
height = 0.08

[sub_resource type="StandardMaterial3D" id="StandardMaterial3D_door_light"]
resource_local_to_scene = true
albedo_color = Color(0, 1, 0, 1)
emission_enabled = true
emission = Color(0, 1, 0, 1)
emission_energy_multiplier = 2.0

"""

# Insert right after the top [sub_resource...
pos = content.find("[sub_resource ")
if pos != -1:
    content = content[:pos] + sub_resources + content[pos:]

# 2. Add DoorLight under Office
# Find Office node
office_pos = content.find('[node name="Office" type="Node3D"')
if office_pos != -1:
    # Find next node in Office (like Floor) and insert before it or insert as child of Office
    # Let's insert it right after the Office node declaration
    end_of_line = content.find('\n', office_pos)
    door_light_node = """
[node name="DoorLight" type="MeshInstance3D" parent="Office"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2.95, 2.3, 2.5)
mesh = SubResource("SphereMesh_door_light")
surface_material_override/0 = SubResource("StandardMaterial3D_door_light")
"""
    content = content[:end_of_line+1] + door_light_node + content[end_of_line+1:]

# 3. Add CCTVViewport and CCTVCamera
# We will insert them under the root node (Game3D)
root_node_pos = content.find('[node name="Game3D" type="Node3D"')
if root_node_pos != -1:
    end_of_line = content.find('\n', root_node_pos)
    cctv_nodes = """
[node name="CCTVViewport" type="SubViewport" parent="." unique_id=574545020]
handle_input_locally = false
size = Vector2i(320, 240)
render_target_update_mode = 3

[node name="CCTVCamera" type="Camera3D" parent="CCTVViewport"]
transform = Transform3D(-4.37114e-08, 0.173648, -0.984808, 0, 0.984808, 0.173648, 1, 7.5904e-09, -4.30473e-08, -8, 2.2, 2.5)
fov = 65.0
"""
    content = content[:end_of_line+1] + cctv_nodes + content[end_of_line+1:]

with open(tscn_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Game3D.tscn updated successfully!")
