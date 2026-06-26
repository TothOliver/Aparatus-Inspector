from PIL import Image
import os

path = r'c:\Users\Barnen\Desktop\awtbg\Sprites\icon_browser.png'
if os.path.exists(path):
    img = Image.open(path).convert('RGBA')
    width, height = img.size
    
    alpha_counts = {}
    for y in range(height):
        for x in range(width):
            a = img.getpixel((x, y))[3]
            alpha_counts[a] = alpha_counts.get(a, 0) + 1
            
    print("Alpha value distribution:")
    for a in sorted(alpha_counts.keys()):
        print(f"Alpha {a}: {alpha_counts[a]} pixels")
else:
    print("File not found")
