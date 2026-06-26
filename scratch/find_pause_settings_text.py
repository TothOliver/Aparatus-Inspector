with open('c:\\Users\\Barnen\\Desktop\\awtbg\\Scenes\\Game3D.tscn', 'r', encoding='utf-8') as f:
    for idx, line in enumerate(f, 1):
        if 'Pause & Settings' in line:
            print(f"Line {idx}: {line.strip()}")
