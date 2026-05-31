import os

for root, dirs, files in os.walk("."):
    for file in files:
        if file.lower().endswith((".ttf", ".otf", ".woff", ".woff2")):
            print(os.path.join(root, file))
