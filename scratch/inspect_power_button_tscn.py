file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game3D.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

in_pb = False
for idx, line in enumerate(lines):
    if '[node name="PowerButton"' in line:
        in_pb = True
    if in_pb:
        print(f"{idx+1}: {line.strip()}")
    if in_pb and '[node name="Corridor"' in line:
        in_pb = False
        break
