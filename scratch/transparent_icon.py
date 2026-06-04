from PIL import Image

path = r"c:\Users\Barnen\Desktop\awtbg\Sprites\icon_shift_verify.png"
print(f"Adding transparency to {path}...")
img = Image.open(path).convert("RGBA")
datas = img.getdata()

newData = []
for item in datas:
    # If the pixel is close to white (background), make it transparent
    if item[0] > 240 and item[1] > 240 and item[2] > 240:
        newData.append((255, 255, 255, 0)) # fully transparent
    else:
        newData.append(item)

img.putdata(newData)
img.save(path)
print("Transparency added successfully!")
