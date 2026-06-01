import subprocess

# Let's get the commits that modified Scenes/Game.tscn
res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "log", "--oneline", "Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)

commits = [line.split()[0] for line in res.stdout.splitlines() if line]

print(f"Found {len(commits)} commits modifying Game.tscn")
for commit in commits[:10]:
    # Search in that commit's Game.tscn
    res2 = subprocess.run(
        ["C:\\Program Files\\Git\\cmd\\git.exe", "show", f"{commit}:Scenes/Game.tscn"],
        capture_output=True,
        text=True,
        encoding="utf-8"
    )
    content = res2.stdout
    
    # Check if "Help" or "Diagnostic" or "MenuBar" is present in the AparatusInspectorWindow section
    lines = content.splitlines()
    has_menu = False
    for line in lines:
        if "AparatusInspectorWindow" in line:
            # simple check if any menu text is in this version
            pass
        if "MenuBar" in line or 'name="MenuBar"' in line or "MenuDivider" in line:
            has_menu = True
            break
    
    # Also get the commit details
    res_info = subprocess.run(
        ["C:\\Program Files\\Git\\cmd\\git.exe", "show", "--format=%s", "-s", commit],
        capture_output=True,
        text=True,
        encoding="utf-8"
    )
    desc = res_info.stdout.strip()
    print(f"Commit {commit} ({desc}): has MenuBar={has_menu}")
