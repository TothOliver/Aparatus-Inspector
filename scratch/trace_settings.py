import re

def trace_settings_nodes():
    with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game.tscn', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Let's find where Settings_Controller_Script is used
    # e.g., script = ExtResource("Settings_Controller_Script") or script = ExtResource(...)
    # Let's find all occurrences of Settings_Controller_Script in node definitions
    matches = re.finditer(r'\[node\s+name="([^"]+)"[^\]]*\]', content)
    nodes = list(matches)
    
    for i, m in enumerate(nodes):
        start = m.start()
        end = nodes[i+1].start() if i + 1 < len(nodes) else len(content)
        block = content[start:end]
        if 'Settings_Controller_Script' in block:
            print(f"FOUND CONTROLLER NODE: {m.group(1)}")
            print(block)
            
            # Print children of this node. In TSCN, children are listed after the parent node
            # and they have parent paths that start with this node's path or it's nested
            parent_name = m.group(1)
            # Find the path of the node by looking at parent attribute, e.g. parent="DesktopOS" or similar
            # Let's find all nodes in the file and build their paths
            
    # Let's also print all lines in the file that have path="res://Scripts/settings_window_controller.gd"
    # or look for the node structure.
    
trace_settings_nodes()
