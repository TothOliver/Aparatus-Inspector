import os

path = r"C:\Users\Barnen\AppData\Roaming\Godot\app_userdata"
if os.path.exists(path):
    for f in os.listdir(path):
        subpath = os.path.join(path, f)
        if os.path.isdir(subpath):
            log_path = os.path.join(subpath, "terminal_focus_debug.txt")
            if os.path.exists(log_path):
                print(f"FOUND LOG in: {f}")
                with open(log_path, "r", encoding="utf-8") as file:
                    print(file.read())
