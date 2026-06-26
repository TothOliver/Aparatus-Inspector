file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    for line in f:
        if "Script_Slots" in line:
            print(line.strip())
