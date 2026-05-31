import os

found = False
for root, dirs, files in os.walk("."):
    for file in files:
        if file.endswith(".theme"):
            print(os.path.join(root, file))
            found = True

if not found:
    print("No .theme files found in the workspace.")
