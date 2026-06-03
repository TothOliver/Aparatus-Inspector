from PIL import Image
import os

source = r"C:\Users\Barnen\.gemini\antigravity\brain\8dcd1808-0a97-40b0-9cdc-61d44f27943f\project_icon_1780479987225.png"
dest = r"c:\Users\Barnen\Desktop\awtbg\Sprites\project_icon.png"

try:
    img = Image.open(source)
    print(f"Loaded image format: {img.format}, size: {img.size}, mode: {img.mode}")
    # Convert and save as proper PNG
    img.save(dest, format="PNG")
    print(f"Successfully re-saved as a proper PNG at {dest}")
    
    # Remove import file again
    import_file = dest + ".import"
    if os.path.exists(import_file):
        os.remove(import_file)
        print("Removed old import metadata.")
except Exception as e:
    print(f"Error: {e}")
