with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

notepad_start = -1
for i, line in enumerate(lines):
    if 'name="NotepadWindow"' in line:
        notepad_start = i
        break

if notepad_start != -1:
    for j in range(notepad_start, notepad_start + 65):
        if j < len(lines):
            print(f"{j+1}: {lines[j].strip()}")
