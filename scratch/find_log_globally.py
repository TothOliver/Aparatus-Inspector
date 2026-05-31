import os

found = False
for root, dirs, files in os.walk(r"C:\Users\Barnen"):
    # Skip huge directories to avoid slow search
    if "AppData\\Local\\Packages" in root or "AppData\\Local\\Microsoft" in root or "node_modules" in root:
        continue
    if "terminal_focus_debug.txt" in files:
        print(f"Found log at: {os.path.join(root, 'terminal_focus_debug.txt')}")
        with open(os.path.join(root, 'terminal_focus_debug.txt'), "r", encoding="utf-8") as f:
            print(f.read())
        found = True
        break

if not found:
    print("Could not find terminal_focus_debug.txt anywhere in C:\\Users\\Barnen")
