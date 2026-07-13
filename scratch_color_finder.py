import os
import re

def search_colors(directory):
    color_pattern = re.compile(r'(Colors\.[a-zA-Z]+(\[[0-9]+\])?|Color\(0x[0-9a-fA-F]+\))')
    is_dark_pattern = re.compile(r'isDark\s*\?')
    
    results = {}
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    
                file_results = []
                for i, line in enumerate(lines):
                    if color_pattern.search(line):
                        # If the line already has dark mode logic, or if it's transparent, we might skip or just flag
                        if 'Colors.transparent' in line and not color_pattern.search(line.replace('Colors.transparent', '')):
                            continue
                        if is_dark_pattern.search(line) or 'brightness' in line or 'Theme.of' in line:
                            continue
                        
                        # Strip leading whitespace
                        file_results.append((i+1, line.strip()))
                        
                if file_results:
                    results[filepath] = file_results
                    
    return results

if __name__ == '__main__':
    res = search_colors('C:/Users/Imran/mess_manager/lib')
    with open('C:/Users/Imran/mess_manager/scratch_color_report.txt', 'w', encoding='utf-8') as f:
        for file, lines in res.items():
            f.write(f"\n--- {file} ---\n")
            for line_num, line_text in lines:
                f.write(f"Line {line_num}: {line_text}\n")
    print("Report generated.")
