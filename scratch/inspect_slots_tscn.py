file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

in_node = False
current_node = ""
for idx, line in enumerate(lines):
    if line.startswith('[node '):
        current_node = line.strip()
        in_node = True
    elif line.startswith('['):
        in_node = False
    elif in_node and 'script = ExtResource("Script_Slots")' in line:
        print(f"Index {idx+1}: {current_node}")
        # Print a few lines around it
        for j in range(max(0, idx-5), min(len(lines), idx+10)):
            print(f"  {j+1}: {lines[j].strip()}")
