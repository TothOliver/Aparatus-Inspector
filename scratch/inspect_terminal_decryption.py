with open("Scripts/terminal.gd", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "decrypt" in line.lower() or "key" in line.lower() or "code" in line.lower():
        print(f"Line {i+1}: {line.strip()}")
