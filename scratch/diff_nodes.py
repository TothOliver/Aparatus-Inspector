import subprocess
import re

def get_nodes(content):
    nodes = []
    lines = content.splitlines()
    for line in lines:
        if line.startswith("[node "):
            name = re.search(r'name="([^"]+)"', line).group(1)
            parent = re.search(r'parent="([^"]+)"', line)
            parent_str = parent.group(1) if parent else ""
            nodes.append((name, parent_str))
    
    # Filter for nodes inside AparatusInspectorWindow
    inspector_nodes = []
    for name, parent in nodes:
        if name == "AparatusInspectorWindow":
            inspector_nodes.append((name, parent))
        elif parent == "AparatusInspectorWindow" or parent.startswith("AparatusInspectorWindow/"):
            inspector_nodes.append((name, parent))
    return inspector_nodes

# Current workspace
with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    current_content = f.read()

# HEAD commit
res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "show", "HEAD:Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)
head_content = res.stdout

current_nodes = get_nodes(current_content)
head_nodes = get_nodes(head_content)

print("--- HEAD Nodes in AparatusInspectorWindow ---")
for name, parent in head_nodes:
    print(f"Parent: {parent:40} | Name: {name}")

print("\n--- Current Nodes in AparatusInspectorWindow ---")
for name, parent in current_nodes:
    print(f"Parent: {parent:40} | Name: {name}")
