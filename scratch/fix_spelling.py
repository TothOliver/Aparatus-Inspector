import os

files_to_fix = [
    r"c:\Users\Barnen\Desktop\awtbg\Scripts\browser.gd",
    r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn",
    r"c:\Users\Barnen\Desktop\awtbg\Scenes\MainMenu.tscn",
    r"c:\Users\Barnen\Desktop\awtbg\game_design_document.md"
]

replacements = [
    ("Aparatus", "Apparatus"),
    ("aparatus", "apparatus"),
    ("APARATUS", "APPARATUS")
]

for filepath in files_to_fix:
    if os.path.exists(filepath):
        print(f"Processing {filepath}...")
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        original_content = content
        for old, new in replacements:
            content = content.replace(old, new)
        
        if content != original_content:
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"  Fixed spelling in {filepath}")
        else:
            print(f"  No changes needed for {filepath}")
    else:
        print(f"File not found: {filepath}")
