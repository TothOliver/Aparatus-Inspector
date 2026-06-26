import os

def search_files(directory, query):
    matches = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.tscn') or file.endswith('.gd'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                        for line_no, line in enumerate(f, 1):
                            if query in line:
                                matches.append((path, line_no, line.strip()))
                except Exception as e:
                    pass
    return matches

print("SEARCH FOR settings_window_controller.gd:")
for match in search_files('c:\\Users\\Barnen\\Desktop\\awtbg', 'settings_window_controller.gd'):
    print(f"{match[0]}:{match[1]}: {match[2]}")

print("\nSEARCH FOR SettingsPopup in MainMenu.tscn or others:")
for match in search_files('c:\\Users\\Barnen\\Desktop\\awtbg', 'SettingsPopup'):
    if 'MainMenu.tscn' in match[0]:
        print(f"{match[0]}:{match[1]}: {match[2]}")
