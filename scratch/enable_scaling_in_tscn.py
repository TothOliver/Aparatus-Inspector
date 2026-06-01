import os

scene_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(scene_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
in_notepad = False
in_terminal = False

for line in lines:
    new_lines.append(line)
    
    if '[node name="NotepadWindow"' in line:
        in_notepad = True
    elif '[node name="TerminalWindow"' in line:
        in_terminal = True
    elif line.startswith('['):
        in_notepad = False
        in_terminal = False
        
    if in_notepad and 'script = ExtResource("11_window")' in line:
        new_lines.append("is_scalable = true\n")
        print("Added is_scalable = true to NotepadWindow")
        in_notepad = False
    elif in_terminal and 'script = ExtResource("11_window")' in line:
        new_lines.append("is_scalable = true\n")
        print("Added is_scalable = true to TerminalWindow")
        in_terminal = False

with open(scene_path, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print("Game.tscn updated successfully!")
