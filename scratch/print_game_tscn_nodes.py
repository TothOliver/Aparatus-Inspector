with open("Scenes/Game.tscn", "r", encoding="utf-8") as f:
    lines = f.readlines()

def print_around(term, num_lines=15):
    for i, line in enumerate(lines):
        if term in line:
            print(f"--- Found {term} at Line {i+1} ---")
            start = max(0, i - 2)
            end = min(len(lines), i + num_lines)
            for j in range(start, end):
                print(f"{j+1}: {lines[j].strip()}")
            print()

print_around('name="ClockPanel"')
print_around('name="InspectorTab"')
print_around('name="StartMenu"')
print_around('name="ShutdownBtn"')
