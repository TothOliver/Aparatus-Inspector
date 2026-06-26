with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
in_crt = False
for idx, line in enumerate(lines):
    if '[node name="CRTOverlay"' in line:
        in_crt = True
        print(f"L{idx+1}: {line}")
    elif in_crt:
        if line.startswith("[node ") or line.strip() == "":
            in_crt = False
        else:
            print(f"  L{idx+1}: {line}")
