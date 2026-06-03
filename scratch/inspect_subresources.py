import re

def find_subresources(filename):
    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        
    # Find all sub_resource definitions
    matches = re.finditer(r'\[sub_resource\s+type="([^"]+)"\s+id="([^"]+)"\]', content)
    sub_res = list(matches)
    
    results = []
    for i, m in enumerate(sub_res):
        stype = m.group(1)
        sid = m.group(2)
        start = m.start()
        end = sub_res[i+1].start() if i + 1 < len(sub_res) else len(content)
        block = content[start:end]
        if any(k in sid.lower() or k in block.lower() for k in ['slider', 'grouplabel']):
            results.append((sid, block))
    return results

print("=== GAME.TSCN SUB-RESOURCES ===")
for sid, block in find_subresources('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn'):
    print(f"ID: {sid}\n{block}\n")
