import os

path = r"C:\Users\Barnen\AppData\Roaming\Godot\app_userdata"
if os.path.exists(path):
    print("Folders in app_userdata:")
    for f in os.listdir(path):
        print(f"  {f} - exists: {os.path.exists(os.path.join(path, f))}")
        subpath = os.path.join(path, f)
        if os.path.isdir(subpath):
            print(f"    files: {os.listdir(subpath)}")
else:
    print("app_userdata folder not found")
