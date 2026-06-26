import subprocess

res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "log", "--oneline", "Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)
commits = [line.split()[0] for line in res.stdout.splitlines() if line]

for commit in commits[:20]:
    res2 = subprocess.run(
        ["C:\\Program Files\\Git\\cmd\\git.exe", "show", f"{commit}:Scenes/Game.tscn"],
        capture_output=True,
        text=True,
        encoding="utf-8"
    )
    content = res2.stdout
    if "Diagnostic" in content:
        print(f"Commit {commit} contains 'Diagnostic'")
