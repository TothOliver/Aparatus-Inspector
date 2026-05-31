file_path = r"c:\Users\Barnen\Desktop\awtbg\Scenes\Game.tscn"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
in_terminal_body = False
for line in lines:
    if '[node name="TerminalBody"' in line:
        in_terminal_body = True
        print(line)
    elif line.startswith('[node name=') and in_terminal_body:
        in_terminal_body = False
    elif in_terminal_body:
        print(line)
