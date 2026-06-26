from PIL import Image
import os

path = r"c:\Users\Barnen\Desktop\awtbg\Sprites\icon_shift_verify.png"
if not os.path.exists(path):
    print(f"Error: {path} does not exist!")
else:
    print(f"File exists. Size in bytes: {os.path.getsize(path)}")
    try:
        img = Image.open(path)
        print(f"Format: {img.format}, Size: {img.size}, Mode: {img.mode}")
        # Check some pixel values to see if they are transparent
        if img.mode == 'RGBA':
            pixels = list(img.getdata())
            alphas = [p[3] for p in pixels]
            max_alpha = max(alphas)
            min_alpha = min(alphas)
            print(f"RGBA transparency range: {min_alpha} to {max_alpha}")
            # Count opaque pixels
            opaque_count = sum(1 for a in alphas if a > 10)
            print(f"Number of non-transparent pixels: {opaque_count} / {len(pixels)}")
        else:
            print("Image does not have transparency (not RGBA).")
    except Exception as e:
        print(f"Error loading image: {e}")
