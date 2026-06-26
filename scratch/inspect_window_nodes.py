with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

in_notepad = False
count = 0
for i, line in enumerate(lines):
    if 'node name="NotepadWindow"' in line:
        in_notepad = True
    if in_notepad:
        print(f"{i+1}: {line.strip()}")
        count += 1
        if count > 50:
            break
