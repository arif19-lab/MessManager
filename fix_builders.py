import re
import os

def fix_builder(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add isDark to builder: (context) { if it's missing
    pattern = re.compile(r'builder:\s*\(context\)\s*\{')
    
    def repl(m):
        return m.group(0) + '\n        bool isDark = Theme.of(context).brightness == Brightness.dark;'
    
    new_content = pattern.sub(repl, content)
    
    # Remove duplicate isDark if exists
    new_content = new_content.replace('bool isDark = Theme.of(context).brightness == Brightness.dark;\n        bool isDark = Theme.of(context).brightness == Brightness.dark;', 'bool isDark = Theme.of(context).brightness == Brightness.dark;')
    
    # Also fix StatefulBuilder builder: (context, setDialogState) {
    pattern2 = re.compile(r'builder:\s*\(context,\s*setDialogState\)\s*\{')
    new_content = pattern2.sub(repl, new_content)
    new_content = new_content.replace('bool isDark = Theme.of(context).brightness == Brightness.dark;\n        bool isDark = Theme.of(context).brightness == Brightness.dark;', 'bool isDark = Theme.of(context).brightness == Brightness.dark;')
    
    # Replace const Text with Text if it contains isDark
    new_content = re.sub(r'const\s+Text\(([^)]*isDark[^)]*)\)', r'Text(\1)', new_content)
    
    # Some containers might still be white
    new_content = new_content.replace('color: Colors.white,\n                    borderRadius: BorderRadius.circular(24),', 'color: isDark ? const Color(0xFF1E293B) : Colors.white,\n                    borderRadius: BorderRadius.circular(24),')
    new_content = new_content.replace('backgroundColor: Colors.white,\n          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),', 'backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,\n          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)

files = [
    'C:/Users/Imran/mess_manager/lib/screens/expenses_screen.dart',
    'C:/Users/Imran/mess_manager/lib/screens/payments_screen.dart',
    'C:/Users/Imran/mess_manager/lib/screens/fried_fine_screen.dart'
]

for f in files:
    fix_builder(f)
print("Done fixing builders.")
