import os

found = False
for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".gdshader"):
            print(os.path.join(root, file))
            found = True

if not found:
    print("No .gdshader files found in the workspace.")
