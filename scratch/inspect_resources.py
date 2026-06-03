import re

def get_ext_resources(filename):
    resources = {}
    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            if line.startswith('[ext_resource'):
                # Extract path and id
                path_match = re.search(r'path="([^"]+)"', line)
                id_match = re.search(r'id="([^"]+)"', line)
                if path_match and id_match:
                    resources[id_match.group(1)] = path_match.group(1)
    return resources

print("=== GAME.TSCN RESOURCES ===")
game_res = get_ext_resources('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn')
for rid, rpath in sorted(game_res.items()):
    if any(k in rpath.lower() for k in ['font', 'button', 'window', 'icon', 'slider', 'toggle', 'stylebox']):
        print(f"ID {rid} -> {rpath}")

print("\n=== GAME3D.TSCN RESOURCES ===")
game3d_res = get_ext_resources('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game3D.tscn')
for rid, rpath in sorted(game3d_res.items()):
    if any(k in rpath.lower() for k in ['font', 'button', 'window', 'icon', 'slider', 'toggle', 'stylebox']):
        print(f"ID {rid} -> {rpath}")
