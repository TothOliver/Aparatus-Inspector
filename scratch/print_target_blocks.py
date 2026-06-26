with open(r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

nodes = [
    ('[node name="AparatusInspectorWindow"', 'AparatusInspectorWindow'),
    ('[node name="TitleBar" type="NinePatchRect" parent="AparatusInspectorWindow"]', 'TitleBar'),
    ('[node name="CloseButton" type="Button" parent="AparatusInspectorWindow/TitleBar"]', 'CloseButton'),
    ('[node name="ChatManager"', 'ChatManager'),
    ('[node name="DialoguePanel" type="VBoxContainer" parent="AparatusInspectorWindow/ChatManager"', 'DialoguePanel'),
    ('[node name="Option" type="Control" parent="AparatusInspectorWindow"', 'Option'),
    ('[node name="AnswerPanel" type="NinePatchRect" parent="AparatusInspectorWindow/Option"', 'AnswerPanel'),
    ('[node name="Button1" type="Button" parent="AparatusInspectorWindow/Option"', 'Button1'),
    ('[node name="Button2" type="Button" parent="AparatusInspectorWindow/Option"', 'Button2'),
    ('[node name="AcceptTerminate" type="Control" parent="AparatusInspectorWindow"', 'AcceptTerminate'),
    ('[node name="ButtonPanel" type="NinePatchRect" parent="AparatusInspectorWindow/AcceptTerminate"', 'ButtonPanel'),
    ('[node name="GoodButton" type="Button" parent="AparatusInspectorWindow/AcceptTerminate/ButtonPanel"', 'GoodButton'),
    ('[node name="BadButton" type="Button" parent="AparatusInspectorWindow/AcceptTerminate/ButtonPanel"', 'BadButton'),
    ('[node name="Model" type="Control" parent="AparatusInspectorWindow"', 'Model'),
    ('[node name="ModelPanel" type="NinePatchRect" parent="AparatusInspectorWindow/Model"', 'ModelPanel'),
    ('[node name="NamePanel" type="Panel" parent="AparatusInspectorWindow/Model"', 'NamePanel'),
    ('[node name="ModelPanel2" type="Panel" parent="AparatusInspectorWindow/Model"', 'ModelPanel2'),
    ('[node name="StatusPanel" type="Panel" parent="AparatusInspectorWindow/Model"', 'StatusPanel'),
    ('[node name="ManuPanel" type="Panel" parent="AparatusInspectorWindow/Model"', 'ManuPanel'),
    ('[node name="Picture" type="Control" parent="AparatusInspectorWindow"', 'Picture'),
    ('[node name="RobotArea" type="NinePatchRect" parent="AparatusInspectorWindow/Picture"', 'RobotArea'),
    ('[node name="RobotTexture" type="TextureRect" parent="AparatusInspectorWindow/Picture"', 'RobotTexture')
]

for pattern, label in nodes:
    pos = content.find(pattern)
    if pos != -1:
        next_node = content.find('[node', pos + len(pattern))
        if next_node != -1:
            block = content[pos:next_node]
        else:
            block = content[pos:]
        print(f"=== {label} ===")
        print(block.strip())
        print("-" * 60)
    else:
        print(f"=== {label} NOT FOUND ===")
