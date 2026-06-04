with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

import re
matches = re.finditer(r'\[node name="Label" type="Label" parent="DesktopOS/DesktopIcons/\w+/VBox"\](.*?)($|\[node)', content, re.DOTALL)
for m in matches:
    print(m.group(0))
