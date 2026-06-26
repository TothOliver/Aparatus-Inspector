import re

with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()

# Find all Label and Button nodes inside windows that lack font_color override
# We want to add black text to nodes inside window bodies (not title bars, not desktop icons)

nodes_to_fix = []

i = 0
while i < len(lines):
    line = lines[i]
    if line.startswith("[node"):
        m_name = re.search(r'name="([^"]+)"', line)
        m_type = re.search(r'type="([^"]+)"', line)
        m_parent = re.search(r'parent="([^"]+)"', line)
        
        node_name = m_name.group(1) if m_name else ""
        node_type = m_type.group(1) if m_type else ""
        parent_name = m_parent.group(1) if m_parent else ""
        
        if node_type in ["Label", "Button"]:
            # Skip desktop icon labels (white text on teal bg)
            if "DesktopIcons" in parent_name:
                i += 1
                continue
            # Skip title bar labels (handled by focus system)
            if "TitleBar" in parent_name and node_name in ["Title", "CloseButton"]:
                i += 1
                continue
            # Skip taskbar tabs (handled in code)
            if "ActiveTabs" in parent_name:
                i += 1
                continue
            # Skip start menu items (already have color overrides) 
            if "StartMenu" in parent_name:
                i += 1
                continue
            # Skip settings body items (already have black text)
            if "SettingsBody" in parent_name:
                i += 1
                continue
            # Skip HackerAlert items
            if "HackerAlert" in parent_name:
                i += 1
                continue
            # Skip StartButton and ClockLabel in Taskbar
            if "Taskbar" in parent_name and node_name in ["StartButton", "QuitButton"]:
                i += 1
                continue
                
            # Check if this node already has a font_color override
            has_font_color = False
            j = i + 1
            while j < len(lines) and not lines[j].startswith("[node") and not lines[j].startswith("[connection"):
                if "theme_override_colors/font_color" in lines[j]:
                    has_font_color = True
                    break
                j += 1
            
            if not has_font_color:
                nodes_to_fix.append((i, node_name, node_type, parent_name))
    i += 1

print(f"Found {len(nodes_to_fix)} nodes to fix:")
for idx, name, ntype, parent in nodes_to_fix:
    print(f"  Line {idx+1}: {name} ({ntype}) in {parent}")

# Now apply fixes - work backwards to preserve line indices
for idx, name, ntype, parent in reversed(nodes_to_fix):
    if ntype == "Button":
        insert_lines = [
            'theme_override_colors/font_color = Color(0, 0, 0, 1)',
            'theme_override_colors/font_pressed_color = Color(0, 0, 0, 1)',
            'theme_override_colors/font_hover_color = Color(0, 0, 0, 1)',
            'theme_override_colors/font_focus_color = Color(0, 0, 0, 1)'
        ]
    else:
        insert_lines = [
            'theme_override_colors/font_color = Color(0, 0, 0, 1)'
        ]
    
    # Insert right after the [node ...] line
    lines[idx+1:idx+1] = insert_lines

with open("Scenes/Game.tscn", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("All font color fixes applied!")
