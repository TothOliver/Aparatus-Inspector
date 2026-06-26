import subprocess

res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "diff", "Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)

diff_lines = res.stdout.splitlines()
matching_lines = []
for idx, line in enumerate(diff_lines):
    if any(keyword in line for keyword in ["MenuBar", "MenuDivider", "File", "Diagnostic", "System", "Help"]):
        matching_lines.append((idx + 1, line))

print("Matching lines in git diff:")
for line_no, line in matching_lines[:50]:
    print(f"L{line_no}: {line}")
