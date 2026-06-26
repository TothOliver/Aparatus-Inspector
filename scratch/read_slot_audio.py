with open("Scripts/slot_machine.gd", "r", encoding="utf-8") as f:
    content = f.read()

lines = content.splitlines()
audio_lines = []
for idx, line in enumerate(lines):
    if any(keyword in line.lower() for keyword in ["audio", "sound", "stream", "play", "synth", "volume"]):
        audio_lines.append((idx + 1, line))

print(f"Found {len(audio_lines)} audio-related lines in slot_machine.gd:")
for line_no, content in audio_lines[:100]:
    print(f"L{line_no}: {content}")
