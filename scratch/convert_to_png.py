from PIL import Image

path = "Sprites/icon_browser.png"
img = Image.open(path)
img.save(path, "PNG")
print("Successfully converted icon_browser.png to true PNG format.")
