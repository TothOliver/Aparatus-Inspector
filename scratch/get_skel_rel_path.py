import os, re

imported_dir = r"c:\Users\johan\OneDrive\Desktop\awtbg\.godot\imported"
for f in os.listdir(imported_dir):
    if "themimicv2byspade1.glb" in f and f.endswith(".scn"):
        filepath = os.path.join(imported_dir, f)
        with open(filepath, "rb") as scn_file:
            content = scn_file.read()
            # find printable ASCII strings >= 4 chars
            strings = [s.decode('ascii') for s in re.findall(b'[\x20-\x7e]{4,}', content)]
            for s in strings:
                if "Skeleton" in s or "General" in s or "Armature" in s or "Node3D" in s or "Character" in s:
                    print(f"Matched string in {f}: {s}")
