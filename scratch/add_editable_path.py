import os

tscn_path = r"c:\Users\johan\OneDrive\Desktop\awtbg\Scenes\MonsterCharacter.tscn"

with open(tscn_path, "r", encoding="utf-8") as f:
    content = f.read()

if "[editable path=\"themimicv2byspade1\"]" not in content:
    content += "\n[editable path=\"themimicv2byspade1\"]\n"
    with open(tscn_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Added editable path to MonsterCharacter.tscn")
