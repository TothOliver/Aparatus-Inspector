import re

with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn', 'r', encoding='utf-8') as f:
    content = f.read()

# Let's find matches for [sub_resource ... id="..."]
matches = list(re.finditer(r'\[sub_resource\s+type="([^"]+)"\s+id="([^"]+)"\]', content))

for i, m in enumerate(matches):
    sid = m.group(2)
    if 'slider' in sid.lower() or 'grouplabel' in sid.lower():
        start = m.start()
        end = matches[i+1].start() if i+1 < len(matches) else len(content)
        block = content[start:end]
        block_lines = block.split('\n')[:20]
        print(f"Subresource ID: {sid}\n" + "\n".join(block_lines) + "\n")
