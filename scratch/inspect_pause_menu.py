file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game3D.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
in_pm = False
for idx, line in enumerate(lines):
    if 'name="PauseMenu"' in line:
        in_pm = True
    if in_pm:
        print(f"{idx+1}: {line.strip()}")
    if in_pm and line.startswith('[node ') and not "PauseMenu" in line and not "PauseWindow" in line and not "TitleBar" in line and not "Title" in line and not "CloseButton" in line and not "SettingsBody" in line and not "DisplayGroup" in line and not "DisplayGroupLabel" in line and not "CRTCheckbox" in line and not "AudioGroup" in line and not "AudioGroupLabel" in line and not "VolumeLabel" in line and not "VolumeValueLabel" in line and not "VolumeSlider" in line and not "MouseGroup" in line and not "MouseGroupLabel" in line and not "SensitivityLabel" in line and not "SensitivityValueLabel" in line and not "SensitivitySlider" in line:
        # Stop printing if we hit a node outside the PauseMenu hierarchy
        # Let's see what nodes are after it
        if not any(x in line for x in ["Pause", "Settings", "CRT", "Volume", "Sensitivity", "Display", "Audio", "Mouse"]):
            in_pm = False
            break
