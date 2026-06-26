import os
from PIL import Image

path = "Sprites/icon_browser.png"
if os.path.exists(path):
    size_bytes = os.path.getsize(path)
    print(f"File exists: size={size_bytes} bytes")
    try:
        with Image.open(path) as img:
            print(f"Image load success: size={img.size}, format={img.format}")
    except Exception as e:
        print(f"Image load error: {e}")
else:
    print("File does not exist!")
