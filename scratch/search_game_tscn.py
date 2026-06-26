with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "settings_window_controller.gd" in line or "Settings_Controller" in line:
        print(f"Line {i+1}: {line.strip()}")
