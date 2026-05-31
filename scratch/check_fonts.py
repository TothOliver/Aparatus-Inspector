import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()
ext_ids = re.findall(r'path="[^"]*M 8pt\.ttf"[^>]*id="([^"]+)"', content)
print("Ext IDs for M 8pt.ttf:", ext_ids)

bold_ids = re.findall(r'path="[^"]*windows-bold[^"]*"[^>]*id="([^"]+)"', content)
print("Ext IDs for Bold Font:", bold_ids)

# Let's find font sizes used with these fonts
all_m8pt_sizes = set()
all_bold_sizes = set()

# Parse the nodes in Game.tscn to see font sizes
# Let's search for lines containing font overrides and sizes
lines = content.splitlines()
for idx, line in enumerate(lines):
    if "theme_override_fonts/font =" in line:
        # check next few lines for font_size
        font_id = re.search(r'ExtResource\("([^"]+)"\)', line)
        if font_id:
            fid = font_id.group(1)
            # scan down for font_size
            for j in range(idx+1, min(idx+15, len(lines))):
                if "font_size =" in lines[j]:
                    size_val = re.search(r'font_size = (\d+)', lines[j])
                    if size_val:
                        val = int(size_val.group(1))
                        if fid in ext_ids:
                            all_m8pt_sizes.add(val)
                        elif fid in bold_ids:
                            all_bold_sizes.add(val)

print("M 8pt.ttf sizes:", all_m8pt_sizes)
print("Bold font sizes:", all_bold_sizes)
