from PIL import Image

path = r"c:\Users\Barnen\Desktop\awtbg\Sprites\icon_shift_verify.png"
print(f"Resizing {path}...")
img = Image.open(path)
img = img.resize((48, 48), Image.Resampling.LANCZOS)
img.save(path)
print("Resized successfully!")
