import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()
# Let's find occurrences of 9_71axn
matches = re.finditer(r'9_71axn', content)
for m in matches:
    idx = m.start()
    # print surrounding text
    start = max(0, idx - 100)
    end = min(len(content), idx + 200)
    print("MATCH:\n", content[start:end])
    print("-" * 50)
