from PIL import Image
import os

path = r'c:\Users\Barnen\Desktop\awtbg\Sprites\icon_browser.png'
if os.path.exists(path):
    img = Image.open(path).convert('RGBA')
    width, height = img.size
    
    # We will do a Breadth-First Search (BFS) from the 4 corners
    # to find the background pixels that are connected to the borders.
    visited = set()
    queue = [(0, 0), (width - 1, 0), (0, height - 1), (width - 1, height - 1)]
    for p in queue:
        visited.add(p)
        
    while queue:
        x, y = queue.pop(0)
        
        # Check 4-way neighbors
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < width and 0 <= ny < height:
                if (nx, ny) not in visited:
                    r, g, b, a = img.getpixel((nx, ny))
                    # Traverse if the alpha is less than 240 (semi-transparent background)
                    if a < 240:
                        visited.add((nx, ny))
                        queue.append((nx, ny))
                        
    # Set all visited background pixels to fully transparent
    for x, y in visited:
        img.putpixel((x, y), (0, 0, 0, 0))
        
    # Also clean up any isolated pixels at the extreme borders that might have been missed
    # just in case there's an outer frame that has a slightly higher alpha.
    # Let's inspect the entire image's alpha values, if a pixel has alpha < 180 it's definitely background.
    for y in range(height):
        for x in range(width):
            r, g, b, a = img.getpixel((x, y))
            if a < 180:
                img.putpixel((x, y), (0, 0, 0, 0))
                
    # Save the modified image back to the sprites folder
    img.save(path, 'PNG')
    print(f"Successfully processed {path}. Made {len(visited)} background pixels transparent.")
else:
    print("File not found")
