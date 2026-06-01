with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    tscn = f.read()

import re
matches = re.findall(r'\[node name="[^"]*Menu[^"]*".*?\]|\[node name="[^"]*Help[^"]*".*?\]|\[node name="[^"]*Diag[^"]*".*?\]', tscn, re.IGNORECASE)
for m in matches:
    print(m)
