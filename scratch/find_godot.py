import os

search_paths = [
    "C:\\Program Files",
    "C:\\Program Files (x86)",
    "C:\\Users\\Barnen\\Downloads",
    "C:\\Users\\Barnen\\Desktop",
    os.getcwd()
]

found = []
for path in search_paths:
    if os.path.exists(path):
        for root, dirs, files in os.walk(path):
            # prune directories to speed up
            if any(p in root for p in [".git", ".godot", "node_modules", "AppData"]):
                continue
            for file in files:
                if "godot" in file.lower() and file.endswith(".exe"):
                    found.append(os.path.join(root, file))

print("Found Godot Executables:")
for f in found:
    print(f)
