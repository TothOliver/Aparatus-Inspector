with open("c:/Users/Barnen/Desktop/awtbg/Scenes/Game3D.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for idx in range(520, 545):
    print(f"{idx+1}: {lines[idx].strip()}")
