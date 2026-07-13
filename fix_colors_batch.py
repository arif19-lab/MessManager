import os

def replace_in_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in replacements:
        content = content.replace(old, new)
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Updated {filepath}")

# expenses_screen.dart
expenses_path = 'C:/Users/Imran/mess_manager/lib/screens/expenses_screen.dart'
expenses_reps = [
    ("color: const Color(0xFF5B1D1D)", "color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFF5B1D1D)"),
    ("color: Colors.white,\n                                  fontWeight: FontWeight.bold", "color: isDark ? Colors.white : Colors.white,\n                                  fontWeight: FontWeight.bold"),
    ("color: Colors.grey[600]", "color: isDark ? Colors.grey[300] : Colors.grey[600]"),
    ("backgroundColor: Colors.white,", "backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,"),
    ("style: TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("color: const Color(0xFFF8FAFC)", "color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)"),
    ("style: const TextStyle(color: Colors.grey", "style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey"),
    ("style: const TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
]

if os.path.exists(expenses_path):
    replace_in_file(expenses_path, expenses_reps)

# home_screen.dart
home_path = 'C:/Users/Imran/mess_manager/lib/screens/home_screen.dart'
home_reps = [
    ("color: const Color(0xFF0F172A),", "color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A),"),
    ("backgroundColor: Colors.white", "backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white"),
    ("color: Colors.white,\n                borderRadius: BorderRadius.circular(20),", "color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,\n                borderRadius: BorderRadius.circular(20),"),
    ("backgroundColor: Colors.grey[300]", "backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300]")
]
if os.path.exists(home_path):
    replace_in_file(home_path, home_reps)

# payments_screen.dart
payments_path = 'C:/Users/Imran/mess_manager/lib/screens/payments_screen.dart'
payments_reps = [
    ("color: const Color(0xFFF8FAFC),", "color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),"),
    ("color: Colors.white,\n                        borderRadius:", "color: isDark ? const Color(0xFF1E293B) : Colors.white,\n                        borderRadius:"),
    ("color: Colors.black87", "color: isDark ? Colors.white : Colors.black87"),
    ("backgroundColor: Colors.white,", "backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,"),
    ("style: TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Colors.grey", "style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey"),
    ("color: Colors.grey[600]", "color: isDark ? Colors.grey[300] : Colors.grey[600]"),
    ("color: Colors.black,", "color: isDark ? Colors.white : Colors.black,")
]
if os.path.exists(payments_path):
    replace_in_file(payments_path, payments_reps)

# people_screen.dart
people_path = 'C:/Users/Imran/mess_manager/lib/screens/people_screen.dart'
people_reps = [
    ("color: const Color(0xFFF8FAFC),", "color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),"),
    ("backgroundColor: Colors.white", "backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white"),
    ("style: TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Colors.grey", "style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey"),
]
if os.path.exists(people_path):
    replace_in_file(people_path, people_reps)

# summary_screen.dart
summary_path = 'C:/Users/Imran/mess_manager/lib/screens/summary_screen.dart'
summary_reps = [
    ("color: const Color(0xFFF8FAFC),", "color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),"),
    ("color: Colors.white,\n                        borderRadius:", "color: isDark ? const Color(0xFF1E293B) : Colors.white,\n                        borderRadius:"),
    ("backgroundColor: Colors.white", "backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white"),
    ("style: TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
]
if os.path.exists(summary_path):
    replace_in_file(summary_path, summary_reps)

# fried_fine_screen.dart
fried_fine_path = 'C:/Users/Imran/mess_manager/lib/screens/fried_fine_screen.dart'
fried_fine_reps = [
    ("backgroundColor: Colors.white", "backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white"),
    ("style: TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Color(0xFF1E293B)", "style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)"),
    ("style: const TextStyle(color: Colors.grey", "style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey"),
]
if os.path.exists(fried_fine_path):
    replace_in_file(fried_fine_path, fried_fine_reps)

print("Done replacing.")
