import os

path = r"C:\Users\Barnen\AppData\Roaming\Godot\app_userdata\AWTBG\terminal_focus_debug.txt"
print("Exists:", os.path.exists(path))
if os.path.exists(path):
    with open(path, "r", encoding="utf-8") as f:
        print(f.read())
