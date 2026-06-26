import os
from PIL import Image

image_path = r"c:\Users\Barnen\Desktop\awtbg\Sprites\icon_browser.png"
if os.path.exists(image_path):
    print("File exists, size:", os.path.getsize(image_path))
    try:
        with Image.open(image_path) as img:
            print("Format:", img.format)
            print("Size:", img.size)
            print("Mode:", img.mode)
    except Exception as e:
        print("Error opening image:", e)
else:
    print("File does not exist")
