try:
    from PIL import Image
    import os
    print("Pillow is installed!")
    for f in os.listdir("Sprites"):
        if f.endswith(".png") and "icon_" in f:
            img = Image.open(os.path.join("Sprites", f))
            print(f"{f}: {img.size} {img.mode}")
except ImportError:
    print("Pillow is NOT installed!")
