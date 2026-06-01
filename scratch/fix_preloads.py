def fix_file(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    new_content = content.replace('preload("res://Sprites/icon_browser.png")', 'load("res://Sprites/icon_browser.png")')
    if new_content != content:
        with open(path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print(f"Fixed {path}")

fix_file("Scripts/desktop_controller.gd")
fix_file("Scripts/browser.gd")
