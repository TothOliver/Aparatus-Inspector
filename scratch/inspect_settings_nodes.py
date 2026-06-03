import re

def get_node_block(filename, search_pattern):
    try:
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            
        # Find matches for node definitions containing search_pattern
        matches = re.finditer(r'\[node\s+name="([^"]+)"[^\]]*\]', content)
        nodes = list(matches)
        
        results = []
        for i, m in enumerate(nodes):
            name = m.group(1)
            if search_pattern.lower() in name.lower():
                # Extract content until the next node or end of file
                start = m.start()
                end = nodes[i+1].start() if i + 1 < len(nodes) else len(content)
                block = content[start:end]
                results.append((name, block))
        return results
    except Exception as e:
        return [("error", str(e))]

print("=== GAME.TSCN SETTINGS NODES ===")
for name, block in get_node_block('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn', 'Settings'):
    if 'slider' in block.lower() or 'checkbox' in block.lower() or 'label' in block.lower() or 'button' in block.lower() or 'title' in block.lower():
        print(f"Node: {name}\n{block}\n")

print("=== GAME3D.TSCN SETTINGS NODES ===")
for name, block in get_node_block('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game3D.tscn', 'Settings'):
    print(f"Node: {name}\n{block}\n")
