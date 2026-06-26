import os

def find_change_scene_calls(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.gd'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                        for line_no, line in enumerate(f, 1):
                            if 'change_scene' in line:
                                print(f"{path}:{line_no}: {line.strip()}")
                except Exception as e:
                    pass

find_change_scene_calls('c:\\Users\\Barnen\\Desktop\\awtbg\\Scripts')
