from PIL import Image

def print_image_info(path):
    try:
        with Image.open(path) as img:
            print(f"{path}: size={img.size}, format={img.format}")
    except Exception as e:
        print(f"Error reading {path}: {e}")

print_image_info("RetroWindowsGUI/Window_Header.png")
print_image_info("RetroWindowsGUI/Window_Header_Inactive.png")
print_image_info("RetroWindowsGUI/Window_Base.png")
