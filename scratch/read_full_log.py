path = r"C:\Users\Barnen\AppData\Roaming\Godot\app_userdata\AWTBG\terminal_focus_debug.txt"
with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")
for line in lines[-30:]:  # Print last 30 lines
    print(line.strip())
