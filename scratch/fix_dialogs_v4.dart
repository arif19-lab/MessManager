import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;
      
      // 1. Change alpha: 0.1 to a better tinted color
      String oldSystemBg = "system: Colors.white.withValues(alpha: 0.1),";
      String newSystemBg = "system: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),";
      if (content.contains(oldSystemBg)) {
        content = content.replaceAll(oldSystemBg, newSystemBg);
        changed = true;
      }
      
      // 2. Wrap Center( and AlertDialog( with BackdropFilter
      // Note: We only want to wrap the return statements inside builders!
      
      content = content.replaceAll(
        'return Center(',
        'return themeProvider.isSystemMode ? BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), child: Center('
      );
      
      content = content.replaceAll(
        'return AlertDialog(',
        'return themeProvider.isSystemMode ? BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), child: AlertDialog('
      );
      
      // Fix closing parentheses for the newly added BackdropFilter
      // Actually, if we do this, we MUST add `)` at the end of the Center/AlertDialog.
      // Since replacing the end is hard, what if we use showGeneralDialog instead of showDialog?
      // No, let's just use the fact that the builder ends with `);`?
      // Better idea: replace the entire `showDialog(` block with a custom function `showGlassyDialog(`?
      // I already created `showGlassDialog` in my thought process but didn't save it!
      
    }
  }
}
