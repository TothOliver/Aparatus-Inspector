with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "ShaderMaterial_crt" in line or "shader_parameter" in line:
        print(f"{i+1}: {line.rstrip()}")
