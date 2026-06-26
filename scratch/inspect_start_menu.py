with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i in range(761, 815):
    print(f"{i+1}: {lines[i].strip()}")
