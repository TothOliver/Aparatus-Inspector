import re

file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Find all nodes related to TerminalWindow
nodes = re.findall(r'\[node name="([^"]+)"[^\]]*type="([^"]+)"[^\]]*parent="([^"]*)"', content)
print("--- NODES IN GAME.TSCN ---")
terminal_nodes = []
for name, type_name, parent in nodes:
    if "Terminal" in name or "Terminal" in parent or name in ["InputField", "OutputLog"]:
        terminal_nodes.append((name, type_name, parent))
        print(f"Node: {name} (type: {type_name}, parent: {parent})")

# Let's search for terminal block configurations
print("\n--- DETAILED NODE CONFIG FOR TERMINAL ---")
lines = content.splitlines()
in_terminal_node = False
for line in lines:
    if line.startswith('[node name="TerminalWindow"') or line.startswith('[node name="InputField"') or line.startswith('[node name="OutputLog"'):
        in_terminal_node = True
        print(line)
    elif line.startswith('['):
        in_terminal_node = False
    elif in_terminal_node:
        print(line)
