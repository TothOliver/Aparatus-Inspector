with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

pos = content.find('[node name="NotepadWindow"')
if pos != -1:
    print(content[pos:pos+1500])
else:
    print("NotepadWindow not found!")
