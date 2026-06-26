import os

log_dir = r"C:\Users\Barnen\AppData\Roaming\Godot\app_userdata\AWTBG\logs"
if os.path.exists(log_dir):
    files = sorted(os.listdir(log_dir), key=lambda x: os.path.getmtime(os.path.join(log_dir, x)), reverse=True)
    for f in files[:3]:
        print(f"Log: {f}")
        filepath = os.path.join(log_dir, f)
        with open(filepath, "r", encoding="utf-8", errors="ignore") as file:
            lines = file.readlines()
        for line in lines:
            if "shader" in line.lower() or "error" in line.lower() or "fail" in line.lower() or "warn" in line.lower():
                print("  " + line.strip())
else:
    print("Log directory does not exist.")
