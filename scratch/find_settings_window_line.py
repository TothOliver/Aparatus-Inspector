content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()
idx = content.find('[node name="SettingsWindow"')
if idx != -1:
    before = content[:idx]
    line_num = before.count('\n') + 1
    print("SettingsWindow starts at line:", line_num)
else:
    print("Not found")
