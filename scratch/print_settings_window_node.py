with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

# Find SettingsWindow definition
pos = content.find('[node name="SettingsWindow"')
if pos != -1:
    # Print the next 150 lines from this position
    print(content[pos:pos+4000])
else:
    print("SettingsWindow node not found!")
