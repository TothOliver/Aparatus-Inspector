import os

path = "terminal_focus_debug.txt"
if os.path.exists(path):
    print("Log file content:")
    with open(path, "r", encoding="utf-8") as f:
        print(f.read())
else:
    print(f"Log file not found at: {os.path.abspath(path)}")
