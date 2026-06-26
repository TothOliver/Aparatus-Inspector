import os

log_dir = r"C:\Users\Barnen\AppData\Roaming\Godot\app_userdata\AWTBG\logs"
if os.path.exists(log_dir):
    files = sorted(os.listdir(log_dir), key=lambda x: os.path.getmtime(os.path.join(log_dir, x)), reverse=True)
    if files:
        f = files[0]
        print(f"Checking latest log: {f}")
        filepath = os.path.join(log_dir, f)
        with open(filepath, "r", encoding="utf-8", errors="ignore") as file:
            content = file.read()
        
        # Look for compiler errors
        lines = content.splitlines()
        errors = [l for l in lines if "error" in l.lower() or "fail" in l.lower() or "shader" in l.lower()]
        if errors:
            print("Found errors:")
            for e in errors[:10]:
                print("  " + e)
        else:
            print("No errors found in latest log!")
else:
    print("Log directory does not exist.")
