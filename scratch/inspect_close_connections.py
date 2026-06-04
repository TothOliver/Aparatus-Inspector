with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

import re
matches = re.finditer(r'\[connection signal="pressed" parent="(\w+/TitleBar/CloseButton)" method="(\w+)"', content)
for m in matches:
    print(f"Signal: {m.group(1)} -> {m.group(2)}")

matches2 = re.finditer(r'\[connection signal="pressed" parent="(\w+/CloseButton)" method="(\w+)"', content)
for m in matches2:
    print(f"Signal: {m.group(1)} -> {m.group(2)}")
