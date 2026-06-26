import re

with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game3D.tscn', 'r', encoding='utf-8') as f:
    content = f.read()

# Find all nodes that have "Switch" or "Button" in their name
matches = re.finditer(r'\[node\s+name="([^"]+)"[^\]]*\]', content)
nodes = list(matches)

for i, m in enumerate(nodes):
    name = m.group(1)
    if 'switch' in name.lower() or 'button' in name.lower() or 'light' in name.lower():
        start = m.start()
        end = nodes[i+1].start() if i + 1 < len(nodes) else len(content)
        block = content[start:end]
        print(f"Node: {name}\n{block.strip()}\n")
