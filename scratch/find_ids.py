file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    for line in f:
        if "13_terminal" in line or "11_window" in line:
            print(line.strip())
