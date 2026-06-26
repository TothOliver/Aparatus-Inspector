import shutil
import os

source = r"C:\Users\Barnen\.gemini\antigravity\brain\8dcd1808-0a97-40b0-9cdc-61d44f27943f\project_icon_1780479987225.png"
dest = r"c:\Users\Barnen\Desktop\awtbg\Sprites\project_icon.png"

# Copy file
shutil.copy(source, dest)
print(f"Copied icon to {dest}")

# Clean up any import cache file if exists to let Godot regenerate it
import_file = dest + ".import"
if os.path.exists(import_file):
    os.remove(import_file)
    print("Cleaned up old import metadata.")
