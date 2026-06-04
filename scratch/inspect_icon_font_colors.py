with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

pos = content.find('name="InspectorIcon"')
if pos != -1:
    print(content[pos:pos+1200])
else:
    print("InspectorIcon not found!")
