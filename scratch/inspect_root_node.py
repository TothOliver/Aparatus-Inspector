file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
count = 0
with open(file_path, "r", encoding="utf-8") as f:
    for line in f:
        line_s = line.strip()
        if line_s.startswith('[node '):
            print(line_s)
            count += 1
            if count >= 15:
                break
