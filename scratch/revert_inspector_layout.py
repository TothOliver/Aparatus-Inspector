import re

scene_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(scene_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Let's define the replacements to revert to the wide layout.
replacements = [
    # 1. AparatusInspectorWindow position/size: wide (width 1060, height 800)
    (
        r'(\[node name="AparatusInspectorWindow"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 180.0\noffset_top = 40.0\noffset_right = 530.0\noffset_bottom = 980.0',
        r'\1offset_left = 180.0\noffset_top = 40.0\noffset_right = 1240.0\noffset_bottom = 840.0'
    ),
    
    # 2. TitleBar inside AparatusInspectorWindow (width 1048)
    (
        r'(\[node name="TitleBar" type="NinePatchRect" parent="AparatusInspectorWindow"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 6.0\noffset_top = 6.0\noffset_right = 344.0\noffset_bottom = 36.0',
        r'\1offset_left = 6.0\noffset_top = 6.0\noffset_right = 1054.0\noffset_bottom = 36.0'
    ),
    
    # 3. CloseButton inside TitleBar (width 18, height 18 -> offset_left = 1024)
    (
        r'(\[node name="CloseButton" type="Button" parent="AparatusInspectorWindow/TitleBar"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 314.0\noffset_top = 6.0\noffset_right = 332.0\noffset_bottom = 24.0',
        r'\1offset_left = 1024.0\noffset_top = 6.0\noffset_right = 1042.0\noffset_bottom = 24.0'
    ),
    
    # 4. ChatManager position/size: width 515, height 470
    (
        r'(\[node name="ChatManager"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 10.0\noffset_top = 450.0\noffset_right = 340.0\noffset_bottom = 740.0',
        r'\1offset_left = 275.0\noffset_top = 50.0\noffset_right = 790.0\noffset_bottom = 520.0'
    ),
    
    # 5. Option panel position/size: width 515, height 230
    (
        r'(\[node name="Option" type="Control" parent="AparatusInspectorWindow"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 10.0\noffset_top = 750.0\noffset_right = 340.0\noffset_bottom = 870.0',
        r'\1offset_left = 275.0\noffset_top = 530.0\noffset_right = 790.0\noffset_bottom = 760.0'
    ),
    
    # 6. AnswerPanel inside Option: width 515, height 230
    (
        r'(\[node name="AnswerPanel" type="NinePatchRect" parent="AparatusInspectorWindow/Option"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 0.0\noffset_top = 0.0\noffset_right = 330.0\noffset_bottom = 120.0',
        r'\1offset_left = 0.0\noffset_top = 0.0\noffset_right = 515.0\noffset_bottom = 230.0'
    ),
    
    # 7. Button1 inside Option: width 485, height 90, font_size = 18
    (
        r'(\[node name="Button1" type="Button" parent="AparatusInspectorWindow/Option"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 15.0\noffset_right = 315.0\noffset_bottom = 50.0\n((?:[^\n\[]*\n)*)theme_override_font_sizes/font_size = 12',
        r'\1offset_left = 15.0\noffset_top = 20.0\noffset_right = 500.0\noffset_bottom = 110.0\n\2theme_override_font_sizes/font_size = 18'
    ),
    
    # 8. Button2 inside Option: width 485, height 90, font_size = 18
    (
        r'(\[node name="Button2" type="Button" parent="AparatusInspectorWindow/Option"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 60.0\noffset_right = 315.0\noffset_bottom = 95.0\n((?:[^\n\[]*\n)*)theme_override_font_sizes/font_size = 12',
        r'\1offset_left = 15.0\noffset_top = 120.0\noffset_right = 500.0\noffset_bottom = 210.0\n\2theme_override_font_sizes/font_size = 18'
    ),
    
    # 9. AcceptTerminate panel position/size: width 240, height 240
    (
        r'(\[node name="AcceptTerminate" type="Control" parent="AparatusInspectorWindow"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 10.0\noffset_top = 880.0\noffset_right = 340.0\noffset_bottom = 930.0',
        r'\1offset_left = 10.0\noffset_top = 50.0\noffset_right = 250.0\noffset_bottom = 290.0'
    ),
    
    # 10. ButtonPanel inside AcceptTerminate: width 230, height 220
    (
        r'(\[node name="ButtonPanel" type="NinePatchRect" parent="AparatusInspectorWindow/AcceptTerminate"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 0.0\noffset_top = 0.0\noffset_right = 330.0\noffset_bottom = 50.0',
        r'\1offset_left = 10.0\noffset_top = 20.0\noffset_right = 240.0\noffset_bottom = 240.0'
    ),
    
    # 11. GoodButton inside ButtonPanel: width 200, height 65, font_size = 24
    (
        r'(\[node name="GoodButton" type="Button" parent="AparatusInspectorWindow/AcceptTerminate/ButtonPanel"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 10.0\noffset_right = 155.0\noffset_bottom = 40.0\n((?:[^\n\[]*\n)*)theme_override_font_sizes/font_size = 12',
        r'\1offset_left = 15.0\noffset_top = 20.0\noffset_right = 215.0\noffset_bottom = 85.0\n\2theme_override_font_sizes/font_size = 24'
    ),
    
    # 12. BadButton inside ButtonPanel: width 200, height 65, font_size = 24
    (
        r'(\[node name="BadButton" type="Button" parent="AparatusInspectorWindow/AcceptTerminate/ButtonPanel"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 175.0\noffset_top = 10.0\noffset_right = 315.0\noffset_bottom = 40.0\n((?:[^\n\[]*\n)*)theme_override_font_sizes/font_size = 12',
        r'\1offset_left = 15.0\noffset_top = 110.0\noffset_right = 215.0\noffset_bottom = 175.0\n\2theme_override_font_sizes/font_size = 24'
    ),
    
    # 13. Model panel position/size: width 240, height 240
    (
        r'(\[node name="Model" type="Control" parent="AparatusInspectorWindow"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 10.0\noffset_top = 260.0\noffset_right = 340.0\noffset_bottom = 440.0',
        r'\1offset_left = 800.0\noffset_top = 360.0\noffset_right = 1040.0\noffset_bottom = 600.0'
    ),
    
    # 14. InfoPanel inside Model: width 230, height 240
    (
        r'(\[node name="InfoPanel" type="NinePatchRect" parent="AparatusInspectorWindow/Model"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 0.0\noffset_top = 0.0\noffset_right = 330.0\noffset_bottom = 180.0',
        r'\1offset_left = 10.0\noffset_top = 0.0\noffset_right = 240.0\noffset_bottom = 240.0'
    ),
    
    # 15. NamePanel inside Model: width 210, x = 20, y = 20
    (
        r'(\[node name="NamePanel" type="Panel" parent="AparatusInspectorWindow/Model"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 15.0\noffset_right = 315.0\noffset_bottom = 47.0',
        r'\1offset_left = 20.0\noffset_top = 20.0\noffset_right = 230.0\noffset_bottom = 52.0'
    ),
    
    # 16. ModelPanel inside Model: width 210, x = 20, y = 70
    (
        r'(\[node name="ModelPanel" type="Panel" parent="AparatusInspectorWindow/Model"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 55.0\noffset_right = 315.0\noffset_bottom = 32.0',
        r'\1offset_left = 20.0\noffset_top = 70.0\noffset_right = 230.0\noffset_bottom = 32.0'
    ),
    
    # 17. StatusPanel inside Model: width 210, x = 20, y = 120
    (
        r'(\[node name="StatusPanel" type="Panel" parent="AparatusInspectorWindow/Model"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 95.0\noffset_right = 315.0\noffset_bottom = 127.0',
        r'\1offset_left = 20.0\noffset_top = 120.0\noffset_right = 230.0\noffset_bottom = 152.0'
    ),
    
    # 18. ManuPanel inside Model: width 210, x = 20, y = 170
    (
        r'(\[node name="ManuPanel" type="Panel" parent="AparatusInspectorWindow/Model"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 135.0\noffset_right = 315.0\noffset_bottom = 167.0',
        r'\1offset_left = 20.0\noffset_top = 170.0\noffset_right = 230.0\noffset_bottom = 202.0'
    ),
    
    # 19. Picture panel position/size: width 240, height 300
    (
        r'(\[node name="Picture" type="Control" parent="AparatusInspectorWindow"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 10.0\noffset_top = 50.0\noffset_right = 340.0\noffset_bottom = 250.0',
        r'\1offset_left = 800.0\noffset_top = 50.0\noffset_right = 1040.0\noffset_bottom = 350.0'
    ),
    
    # 20. RobotArea inside Picture: width 230, height 300
    (
        r'(\[node name="RobotArea" type="NinePatchRect" parent="AparatusInspectorWindow/Picture"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 0.0\noffset_top = 0.0\noffset_right = 330.0\noffset_bottom = 200.0',
        r'\1offset_left = 10.0\noffset_top = 0.0\noffset_right = 240.0\noffset_bottom = 300.0'
    ),
    
    # 21. RobotTexture inside Picture: width 200, height 270, x = 25, y = 15
    (
        r'(\[node name="RobotTexture" type="TextureRect" parent="AparatusInspectorWindow/Picture"[^\]]*\]\n(?:[^\n\[]*\n)*)offset_left = 15.0\noffset_top = 15.0\noffset_right = 315.0\noffset_bottom = 185.0',
        r'\1offset_left = 25.0\noffset_top = 15.0\noffset_right = 225.0\noffset_bottom = 285.0'
    )
]

modified = content
for pattern, replacement in replacements:
    modified, count = re.subn(pattern, replacement, modified)
    print(f"Reverted (pattern: {pattern[:40]}...), count: {count}")

with open(scene_path, 'w', encoding='utf-8') as f:
    f.write(modified)
print("Reverted Game.tscn to wide layout while preserving dialogue ScrollContainer!")
