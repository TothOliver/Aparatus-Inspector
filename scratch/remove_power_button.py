file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game3D.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Let's define regex pattern to match PowerButton node and all its children up to the Corridor node
import re
pattern = r'\[node name="PowerButton"(?:[^\n]*\n)*?(?=\[node name="Corridor")'

new_content, count = re.subn(pattern, '', content)
print(f"Removed {count} occurrences of PowerButton node block.")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(new_content)
