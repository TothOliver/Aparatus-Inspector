from PIL import Image

image_path = r"c:\Users\Barnen\Desktop\awtbg\Sprites\icon_browser.png"
img = Image.open(image_path)
print("Original format/mode/size:", img.format, img.mode, img.size)

# Convert to RGBA
rgba_img = img.convert("RGBA")

# Let's inspect the corner pixel color to see if we should make it transparent
# Check the top-left pixel
corner_pixel = rgba_img.getpixel((0, 0))
print("Corner pixel color:", corner_pixel)

# If the background is white, we can make it transparent
# Let's check if we want to replace a specific color (like white: 255, 255, 255) with transparent.
# Let's write a transparent version.
data = rgba_img.getdata()
new_data = []
for item in data:
    # If it is white (or very close to white, e.g. > 240 on all channels)
    if item[0] > 240 and item[1] > 240 and item[2] > 240:
        new_data.append((255, 255, 255, 0)) # transparent
    else:
        new_data.append(item)

rgba_img.putdata(new_data)

# Resize to 48x48
resized_img = rgba_img.resize((48, 48), Image.Resampling.LANCZOS)
resized_img.save(image_path, "PNG")
print("Saved resized RGBA image to", image_path)
