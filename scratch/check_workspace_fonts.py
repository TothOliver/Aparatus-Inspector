import os

found_fonts = []
for root, dirs, files in os.walk("."):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    for file in files:
        if file.lower().endswith((".ttf", ".otf", ".woff", ".woff2")):
            found_fonts.append(os.path.join(root, file))

print("Fonts in workspace:")
for font in found_fonts:
    print(font)
