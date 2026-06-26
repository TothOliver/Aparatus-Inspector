with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

# Continue from line 1487 to find OutputLog and InputField
for i in range(1484, 1550):
    print(f"{i+1}: {lines[i].rstrip()}")
