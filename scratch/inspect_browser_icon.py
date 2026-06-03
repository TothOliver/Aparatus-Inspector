from PIL import Image
import os

path = r'c:\Users\Barnen\Desktop\awtbg\Sprites\icon_browser.png'
if os.path.exists(path):
    img = Image.open(path).convert('RGBA')
    width, height = img.size
    print(f"Image Size: {width}x{height}")
    
    # Let's inspect the corner pixels
    corners = [
        (0, 0), (0, 1), (1, 0), (1, 1),
        (width-1, 0), (0, height-1), (width-1, height-1)
    ]
    for c in corners:
        print(f"Pixel at {c}: {img.getpixel(c)}")
        
    # Find all unique colors and their frequency
    colors = {}
    for y in range(height):
        for x in range(width):
            color = img.getpixel((x, y))
            colors[color] = colors.get(color, 0) + 1
            
    # Sort and show top 10 most common colors
    sorted_colors = sorted(colors.items(), key=lambda item: item[1], reverse=True)
    print("\nTop 10 most common colors:")
    for color, freq in sorted_colors[:10]:
        print(f"Color: {color}, Frequency: {freq}")
else:
    print("File not found")
