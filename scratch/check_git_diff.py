import subprocess

res = subprocess.run(
    ["C:\\Program Files\\Git\\cmd\\git.exe", "diff", "Scenes/Game.tscn"],
    capture_output=True,
    text=True,
    encoding="utf-8"
)

diff_lines = res.stdout.splitlines()
deleted_nodes = []
for line in diff_lines:
    if line.startswith("-") and not line.startswith("---"):
        if "node name=" in line:
            deleted_nodes.append(line)

print("Deleted Nodes in Git Diff:")
for node in deleted_nodes:
    print(node)
