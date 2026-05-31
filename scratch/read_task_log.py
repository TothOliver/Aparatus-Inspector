import os

path = r"C:\Users\Barnen\.gemini\antigravity\brain\8dcd1808-0a97-40b0-9cdc-61d44f27943f\.system_generated\tasks\task-1944.log"
if os.path.exists(path):
    print("Task log:")
    with open(path, "r", encoding="utf-8") as f:
        print(f.read())
else:
    print(f"Task log not found at: {path}")
