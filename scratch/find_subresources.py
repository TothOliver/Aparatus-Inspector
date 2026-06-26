import re

content = open('c:/Users/Barnen/Desktop/awtbg/Scenes/Game.tscn', 'r', encoding='utf-8').read()

# Let's find the last sub_resource definition
matches = list(re.finditer(r'\[sub_resource type=\"[^\"]+\" id=\"([^\"]+)\"\]', content))
if matches:
    # Print the last 15 sub_resources
    for m in matches[-15:]:
        print(f"Subresource: {m.group(0)}")
        # print the next few lines
        idx = m.end()
        end_idx = content.find('[', idx)
        if end_idx == -1:
            end_idx = content.find('\n\n', idx)
        print(content[idx:end_idx].strip())
        print("-" * 40)
else:
    print("No subresources found")
