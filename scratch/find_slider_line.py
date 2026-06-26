content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()
idx = content.find('[sub_resource type="StyleBoxTexture" id="StyleBoxTexture_slider"]')
if idx != -1:
    before = content[:idx]
    line_num = before.count('\n') + 1
    print("Starts at line:", line_num)
else:
    print("Not found")
