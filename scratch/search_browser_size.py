import re

files_to_search = ["Scripts/desktop_controller.gd", "Scripts/browser.gd"]
pattern = re.compile(r'size|custom_minimum_size|position|rect|offset', re.IGNORECASE)

for path in files_to_search:
    print(f"\n--- Searching in {path} ---")
    with open(path, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()
    for idx, line in enumerate(lines):
        if pattern.search(line):
            print(f"  L{idx+1}: {line}")
