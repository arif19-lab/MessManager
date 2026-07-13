import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      
      bool changed = false;
      
      String target1 = "builder: (context) {\\n        bool isDark = Theme.of(context).brightness == Brightness.dark;";
      String target2 = "builder: (context) {\\r\\n        bool isDark = Theme.of(context).brightness == Brightness.dark;";
      
      String replacement1 = '''builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;''';
        
      if (content.contains(target1) || content.contains(target2)) {
        content = content.replaceAll(target1, replacement1);
        content = content.replaceAll(target2, replacement1);
        changed = true;
      }
      
      String bgTarget = "backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,";
      String bgTarget2 = "backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white";
      String bgReplacement = '''backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
            system: Colors.white.withValues(alpha: 0.1),
          ),
          elevation: themeProvider.isSystemMode ? 0 : null,''';
          
      if (content.contains(bgTarget) || content.contains(bgTarget2)) {
        content = content.replaceAll(bgTarget, bgReplacement);
        content = content.replaceAll(bgTarget2, bgReplacement);
        changed = true;
      }
      
      String colorTarget = "color: isDark ? const Color(0xFF0A0A0A) : Colors.white,";
      String colorReplacement = '''color: themeProvider.resolveColor(
                      light: Colors.white,
                      dark: const Color(0xFF0A0A0A),
                      system: Colors.white.withValues(alpha: 0.1),
                    ),
                    border: themeProvider.isSystemMode ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,''';
                    
      if (content.contains(colorTarget)) {
        content = content.replaceAll(colorTarget, colorReplacement);
        changed = true;
      }
      
      if (changed) {
        if (!content.contains("import 'package:mess_manager/providers/theme_provider.dart';")) {
          content = "import 'package:mess_manager/providers/theme_provider.dart';\n" + content;
        }
        if (!content.contains("import 'dart:ui' as ui;")) {
          content = "import 'dart:ui' as ui;\n" + content;
        }
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
