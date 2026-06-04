with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

import re
matches = re.finditer(r'\[node name="(\w+Icon)"', content)
for m in matches:
    name = m.group(1)
    pos_idx = content.find('[node name="' + name + '"')
    sub = content[pos_idx:pos_idx+800]
    pos = re.search(r'offset_left = ([\d\.-]+)\s*offset_top = ([\d\.-]+)\s*offset_right = ([\d\.-]+)\s*offset_bottom = ([\d\.-]+)', sub)
    if pos:
        print(f"{name}: left={pos.group(1)}, top={pos.group(2)}, right={pos.group(3)}, bottom={pos.group(4)}")
    else:
        print(f"{name}: no offset found")
