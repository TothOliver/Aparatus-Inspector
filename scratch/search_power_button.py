file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game3D.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
in_power_button = False
for line in lines:
    if "PowerButton" in line or in_power_button:
        print(line)
        if line.startswith("[node name=") and not "PowerButton" in line:
            in_power_button = False
        else:
            in_power_button = True
