import subprocess
import re

res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "show", "HEAD:Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)
content = res.stdout

# Search for File, Diagnostic, System, Help
print("Searching for menu texts in HEAD...")
lines = content.splitlines()
for i, line in enumerate(lines):
    if any(keyword in line for keyword in ["File", "Diagnostic", "System", "Help", "MenuBar", "MenuDivider"]):
        print(f"L{i+1}: {line}")
