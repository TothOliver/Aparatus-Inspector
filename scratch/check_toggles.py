from PIL import Image
import os
for f in os.listdir("RetroWindowsGUI"):
    if 'Toggle' in f:
        img = Image.open(os.path.join("RetroWindowsGUI", f))
        print(f"{f}: {img.size}")
