import subprocess

res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "diff", "Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)

diff_lines = res.stdout.splitlines()
in_window_diff = False
window_diff_lines = []

for line in diff_lines:
    if "AparatusInspectorWindow" in line:
        in_window_diff = True
    elif line.startswith("diff --git"):
        in_window_diff = False
    
    if in_window_diff:
        window_diff_lines.append(line)

print("AparatusInspectorWindow Diff:")
for line in window_diff_lines[:150]:
    print(line)
if len(window_diff_lines) > 150:
    print(f"... and {len(window_diff_lines) - 150} more lines")
