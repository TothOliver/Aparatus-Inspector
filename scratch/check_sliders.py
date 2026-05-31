from PIL import Image
import os
for f in os.listdir("RetroWindowsGUI"):
    if 'Slider' in f and not f.endswith('.import'):
        img = Image.open(os.path.join("RetroWindowsGUI", f))
        print(f"{f}: {img.size}")
