import re

def verify_terminal():
    print("Verifying Scripts/terminal.gd...")
    with open("Scripts/terminal.gd", "r", encoding="utf-8") as f:
        content = f.read()
    
    # Check for correct keys and contents in encrypted_files dict under var encrypted_files
    c1_pos = content.find('"classified_01.enc": {')
    if c1_pos == -1:
        c1_pos = content.find("'classified_01.enc': {")
    if c1_pos == -1:
        print("FAIL: classified_01.enc dictionary key not found in terminal.gd")
        return False
    
    c1_sub = content[c1_pos:c1_pos+700]
    if '"key": "14"' not in c1_sub and "'key': '14'" not in c1_sub:
        print(f"FAIL: classified_01.enc key is not '14'. Substring:\n{c1_sub}")
        return False
    if "2984" not in c1_sub:
        print(f"FAIL: classified_01.enc content does not contain passcode '2984'. Substring:\n{c1_sub}")
        return False
        
    c2_pos = content.find('"classified_02.enc": {')
    if c2_pos == -1:
        c2_pos = content.find("'classified_02.enc': {")
    if c2_pos == -1:
        print("FAIL: classified_02.enc dictionary key not found in terminal.gd")
        return False
    c2_sub = content[c2_pos:c2_pos+700]
    if '"key": "walter"' not in c2_sub and "'key': 'walter'" not in c2_sub:
        print(f"FAIL: classified_02.enc key is not 'walter'. Substring:\n{c2_sub}")
        return False
    if "8841" not in c2_sub:
        print(f"FAIL: classified_02.enc content does not contain passcode '8841'. Substring:\n{c2_sub}")
        return False

    print("SUCCESS: Scripts/terminal.gd contains the correct decryption keys and passcodes.")
    return True

def verify_shift_verify_window():
    print("Verifying Scripts/shift_verify_window.gd...")
    with open("Scripts/shift_verify_window.gd", "r", encoding="utf-8") as f:
        content = f.read()

    # Verify passcodes logic
    # day == 1 -> "2984"
    # day == 2 -> "8841"
    
    match1 = re.search(r"day\s*==\s*1.*?\"2984\"", content, re.DOTALL)
    if not match1:
        match1 = re.search(r"day\s*==\s*1.*?'2984'", content, re.DOTALL)
    if not match1:
        print("FAIL: shift_verify_window.gd passcode logic for day == 1 and '2984' not found.")
        return False

    match2 = re.search(r"day\s*==\s*2.*?\"8841\"", content, re.DOTALL)
    if not match2:
        match2 = re.search(r"day\s*==\s*2.*?'8841'", content, re.DOTALL)
    if not match2:
        print("FAIL: shift_verify_window.gd passcode logic for day == 2 and '8841' not found.")
        return False

    print("SUCCESS: Scripts/shift_verify_window.gd contains correct passcode verification logic.")
    return True

def verify_day_manager():
    print("Verifying Scripts/DayManager.gd...")
    with open("Scripts/DayManager.gd", "r", encoding="utf-8") as f:
        content = f.read()

    # Verify day_configs:
    # 1: {"quota": 3
    # 2: {"quota": 4
    # 3: {"quota": 5
    
    if "1: {\"quota\": 3" not in content and "1: {'quota': 3" not in content:
        print("FAIL: Day 1 quota config is incorrect.")
        return False
    if "2: {\"quota\": 4" not in content and "2: {'quota': 4" not in content:
        print("FAIL: Day 2 quota config is incorrect.")
        return False
    if "3: {\"quota\": 5" not in content and "3: {'quota': 5" not in content:
        print("FAIL: Day 3 quota config is incorrect.")
        return False

    print("SUCCESS: Scripts/DayManager.gd contains correct day quotas.")
    return True

if __name__ == "__main__":
    t1 = verify_terminal()
    t2 = verify_shift_verify_window()
    t3 = verify_day_manager()
    
    if t1 and t2 and t3:
        print("\n--- ALL PARSING CHECKS PASSED ---")
    else:
        print("\n--- SOME PARSING CHECKS FAILED ---")
