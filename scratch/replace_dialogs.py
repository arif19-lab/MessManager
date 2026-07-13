import os
import re

directory = r"C:\Users\Imran\mess_manager\lib\screens"

for filename in os.listdir(directory):
    if not filename.endswith(".dart"): continue
    filepath = os.path.join(directory, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if 'showDialog(' not in content: continue
    
    print(f"File: {filename}")
    
    # Let's count how many showDialog(
    count = content.count('showDialog(')
    print(f"Found {count} showDialog calls.")
