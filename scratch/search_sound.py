import os

for root, dirs, files in os.walk("Scripts"):
    for file in files:
        if file.endswith(".gd"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "Audio" in content or "volume" in content or "sound" in content or "play" in content:
                print(f"{file}:")
                for line in content.splitlines():
                    if any(w in line for w in ["Audio", "volume", "sound", "play", "bus"]):
                        print(f"  {line.strip()}")
