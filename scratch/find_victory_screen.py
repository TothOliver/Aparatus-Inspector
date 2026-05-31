import os
import re

search_dir = 'c:/Users/Barnen/Desktop/awtbg'
for root, dirs, files in os.walk(search_dir):
    for f in files:
        if f.endswith('.tscn') or f.endswith('.gd'):
            path = os.path.join(root, f)
            try:
                content = open(path, 'r', encoding='utf-8').read()
                if "SHIFT COMPLETED" in content or "PERFORMANCE GRADE" in content or "Performance Grade" in content:
                    print("Found in file:", path)
            except Exception as e:
                pass
