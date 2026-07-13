import re

def fix_file(filepath, fixes):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    for old, new in fixes:
        if old in content:
            content = content.replace(old, new)
            print(f"  Fixed: {old[:60].strip()}")
        else:
            print(f"  SKIP (not found): {old[:60].strip()}")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

# ============================================================
# fried_fine_screen.dart
# ============================================================
ff_path = 'C:/Users/Imran/mess_manager/lib/screens/fried_fine_screen.dart'

# 1. _buildMemberSelectorList - no isDark, hardcoded color
ff_fixes = [
    # Add isDark to _buildMemberSelectorList
    (
        'Widget _buildMemberSelectorList(List<Member> members, String? selectedId, ValueChanged<String> onSelected) {\n    return Container(\n      height: 120,\n      decoration: BoxDecoration(\n        color: const Color(0xFFF8FAFC),',
        'Widget _buildMemberSelectorList(List<Member> members, String? selectedId, ValueChanged<String> onSelected) {\n    bool isDark = Theme.of(context).brightness == Brightness.dark;\n    return Container(\n      height: 120,\n      decoration: BoxDecoration(\n        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),'
    ),
    # member name text when not selected
    (
        '                      color: isSelected ? Colors.white : const Color(0xFF1E293B),\n                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,',
        '                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1E293B)),\n                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,'
    ),
    # _showAddFineForMemberDialog - container hardcoded white
    (
        '              decoration: BoxDecoration(\n                color: Colors.white,\n                borderRadius: BorderRadius.circular(24),\n                boxShadow: [\n                  BoxShadow(\n                    color: const Color(0xFF0F172A).withOpacity(0.08),',
        '              decoration: BoxDecoration(\n                color: isDark ? const Color(0xFF1E293B) : Colors.white,\n                borderRadius: BorderRadius.circular(24),\n                boxShadow: [\n                  BoxShadow(\n                    color: const Color(0xFF0F172A).withOpacity(0.08),'
    ),
    # duplicate isDark in StatefulBuilder
    (
        '        bool isDark = Theme.of(context).brightness == Brightness.dark;\n        return StatefulBuilder(\n          builder: (context, setDialogState) {\n        bool isDark = Theme.of(context).brightness == Brightness.dark;',
        '        bool isDark = Theme.of(context).brightness == Brightness.dark;\n        return StatefulBuilder(\n          builder: (context, setDialogState) {'
    ),
    # member card color text  
    (
        '                  const TextStyle(\n                          color: Color(0xFF065F46),\n                          fontWeight: FontWeight.bold,\n                          fontSize: 12,',
        '                  TextStyle(\n                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),\n                          fontWeight: FontWeight.bold,\n                          fontSize: 12,'
    ),
]

print("Fixing fried_fine_screen.dart...")
fix_file(ff_path, ff_fixes)


# ============================================================
# expenses_screen.dart
# ============================================================
exp_path = 'C:/Users/Imran/mess_manager/lib/screens/expenses_screen.dart'
exp_fixes = [
    # Remove duplicate isDark in StatefulBuilder for AddExpense
    (
        '        bool isDark = Theme.of(context).brightness == Brightness.dark;\n        return StatefulBuilder(\n          builder: (context, setDialogState) {\n        bool isDark = Theme.of(context).brightness == Brightness.dark;\n            return Center(',
        '        bool isDark = Theme.of(context).brightness == Brightness.dark;\n        return StatefulBuilder(\n          builder: (context, setDialogState) {\n            return Center('
    ),
    # _buildDialogField - add isDark for text input styling
    (
        '  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {\n    return TextField(',
        '  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {\n    bool isDark = Theme.of(context).brightness == Brightness.dark;\n    return TextField('
    ),
    # _buildDialogField text input field styling
    (
        '      decoration: InputDecoration(\n        labelText: label,\n        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),\n        prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),\n        enabledBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: BorderSide(color: Colors.grey.withOpacity(0.24)),\n        ),\n        focusedBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: const BorderSide(color: Color(0xFF0D9488)),\n        ),\n        contentPadding: const EdgeInsets.symmetric(vertical: 10),\n      ),\n    );\n  }\n}',
        '      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),\n      decoration: InputDecoration(\n        labelText: label,\n        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),\n        prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),\n        filled: isDark,\n        fillColor: isDark ? const Color(0xFF0F172A) : null,\n        enabledBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.24)),\n        ),\n        focusedBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: const BorderSide(color: Color(0xFF0D9488)),\n        ),\n        contentPadding: const EdgeInsets.symmetric(vertical: 10),\n      ),\n    );\n  }\n}'
    ),
    # member unselected text color in selector
    (
        '                      color: isSelected ? Colors.white : const Color(0xFF1E293B),\n                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,\n                      fontSize: 12,',
        '                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1E293B)),\n                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,\n                      fontSize: 12,'
    ),
]

print("\nFixing expenses_screen.dart...")
fix_file(exp_path, exp_fixes)


# ============================================================
# payments_screen.dart
# ============================================================
pay_path = 'C:/Users/Imran/mess_manager/lib/screens/payments_screen.dart'
pay_fixes = [
    # Remove duplicate isDark
    (
        '        bool isDark = Theme.of(context).brightness == Brightness.dark;\n        return StatefulBuilder(\n          builder: (context, setDialogState) {\n        bool isDark = Theme.of(context).brightness == Brightness.dark;',
        '        bool isDark = Theme.of(context).brightness == Brightness.dark;\n        return StatefulBuilder(\n          builder: (context, setDialogState) {'
    ),
    # member unselected text color
    (
        '                    color: isSelected ? Colors.white : const Color(0xFF1E293B),\n                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,\n                      fontSize: 12,',
        '                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1E293B)),\n                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,\n                      fontSize: 12,'
    ),
    # Add text input styling to _buildDialogField or inline fields
    (
        '              decoration: InputDecoration(\n                labelText: \'Payment Amount (BDT)\',\n                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),\n                prefixIcon: Icon(Icons.monetization_on_outlined, color: Colors.grey[400], size: 18),\n                enabledBorder: OutlineInputBorder(\n                  borderRadius: BorderRadius.circular(12),\n                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.24)),\n                ),\n                focusedBorder: OutlineInputBorder(\n                  borderRadius: BorderRadius.circular(12),\n                  borderSide: const BorderSide(color: Color(0xFF0D9488)),\n                ),\n                contentPadding: const EdgeInsets.symmetric(vertical: 10),\n              ),',
        '              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),\n              decoration: InputDecoration(\n                labelText: \'Payment Amount (BDT)\',\n                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),\n                prefixIcon: Icon(Icons.monetization_on_outlined, color: Colors.grey[400], size: 18),\n                filled: isDark,\n                fillColor: isDark ? const Color(0xFF0F172A) : null,\n                enabledBorder: OutlineInputBorder(\n                  borderRadius: BorderRadius.circular(12),\n                  borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.24)),\n                ),\n                focusedBorder: OutlineInputBorder(\n                  borderRadius: BorderRadius.circular(12),\n                  borderSide: const BorderSide(color: Color(0xFF0D9488)),\n                ),\n                contentPadding: const EdgeInsets.symmetric(vertical: 10),\n              ),'
    ),
]

print("\nFixing payments_screen.dart...")
fix_file(pay_path, pay_fixes)


# ============================================================
# people_screen.dart - fix input fields
# ============================================================
peo_path = 'C:/Users/Imran/mess_manager/lib/screens/people_screen.dart'
peo_fixes = [
    # _buildDialogField - add isDark
    (
        '  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {\n    return TextField(',
        '  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {\n    bool isDark = Theme.of(context).brightness == Brightness.dark;\n    return TextField('
    ),
    # input styling
    (
        '      decoration: InputDecoration(\n        labelText: label,\n        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),\n        prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),\n        enabledBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: BorderSide(color: Colors.grey.withOpacity(0.24)),\n        ),\n        focusedBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: const BorderSide(color: Color(0xFF0D9488)),\n        ),\n        contentPadding: const EdgeInsets.symmetric(vertical: 10),\n      ),\n    );\n  }\n}',
        '      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),\n      decoration: InputDecoration(\n        labelText: label,\n        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),\n        prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),\n        filled: isDark,\n        fillColor: isDark ? const Color(0xFF0F172A) : null,\n        enabledBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.withOpacity(0.24)),\n        ),\n        focusedBorder: OutlineInputBorder(\n          borderRadius: BorderRadius.circular(12),\n          borderSide: const BorderSide(color: Color(0xFF0D9488)),\n        ),\n        contentPadding: const EdgeInsets.symmetric(vertical: 10),\n      ),\n    );\n  }\n}'
    ),
]

print("\nFixing people_screen.dart...")
fix_file(peo_path, peo_fixes)


# ============================================================
# notifications_screen.dart
# ============================================================
notif_path = 'C:/Users/Imran/mess_manager/lib/screens/notifications_screen.dart'
print("\nChecking notifications_screen.dart...")
try:
    with open(notif_path, 'r', encoding='utf-8') as f:
        notif_content = f.read()
    print(f"  File loaded, length: {len(notif_content)}")
    
    notif_fixes = [
        ('Colors.white,\n          style: TextStyle(color: Color(0xFF1E293B)', 'isDark ? const Color(0xFF1E293B) : Colors.white,\n          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)'),
    ]
    fix_file(notif_path, notif_fixes)
except Exception as e:
    print(f"  Error: {e}")


# ============================================================
# meals_screen.dart - fix any remaining dialogs
# ============================================================
meals_path = 'C:/Users/Imran/mess_manager/lib/screens/meals_screen.dart'
print("\nChecking meals_screen.dart...")
try:
    with open(meals_path, 'r', encoding='utf-8') as f:
        meals_content = f.read()
    print(f"  File loaded, length: {len(meals_content)}")
except Exception as e:
    print(f"  Error: {e}")


print("\nAll fixes applied.")
