import os
import shutil
from PIL import Image

backup_path = r"C:\Users\Barnen\Desktop\awtbg\Sprites\icon_browser.png"
# Let's see if the artifact exists
artifact_path = r"C:\Users\Barnen\.gemini\antigravity\brain\8dcd1808-0a97-40b0-9cdc-61d44f27943f\icon_browser_1780324189628.png"

if os.path.exists(artifact_path):
    print("Artifact exists!")
    img = Image.open(artifact_path).convert("RGBA")
    print("Artifact size:", img.size)
    
    # Let's inspect the corner pixel color of the original artifact
    corner = img.getpixel((0, 0))
    print("Corner pixel color of artifact:", corner)
    
    # We will make any pixel close to the corner pixel transparent
    # Let's use a threshold of 15
    data = img.getdata()
    new_data = []
    for item in data:
        dist = ((item[0] - corner[0])**2 + (item[1] - corner[1])**2 + (item[2] - corner[2])**2)**0.5
        if dist < 30:
            new_data.append((0, 0, 0, 0)) # transparent
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    
    # Resize to 48x48
    img_48 = img.resize((48, 48), Image.Resampling.LANCZOS)
    img_48.save(backup_path, "PNG")
    print("Successfully processed and saved to", backup_path)
else:
    print("Artifact does not exist at", artifact_path)
