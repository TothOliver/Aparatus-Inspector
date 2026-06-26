with open("Scripts/terminal.gd", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
for idx, line in enumerate(lines):
    if "dir" in line.lower() or "file(s)" in line.lower() or "file_size" in line.lower():
        print(f"L{idx+1}: {line}")
