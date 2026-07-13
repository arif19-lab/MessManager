import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      
      bool changed = false;
      
      // 1. Wrap the widget with BackdropFilter
      // We will look for return Center( or return AlertDialog( and replace them if we inject themeProvider
      
      final builderPattern = RegExp(r'builder:\s*\((context|ctx)\)\s*\{([\s\S]*?)bool\s+isDark\s*=\s*Theme\.of\((.*?)\)\.brightness\s*==\s*Brightness\.dark;');
      
      content = content.replaceAllMapped(builderPattern, (match) {
        changed = true;
        String arg = match.group(1)!;
        String prefix = match.group(2)!;
        String ctxArg = match.group(3)!;
        return 'builder: ($arg) {$prefix' +
            'final themeProvider = Provider.of<ThemeProvider>($ctxArg, listen: false);\n        ' +
            'bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;';
      });
      
      // Replace dialog container backgrounds
      final bgPattern1 = RegExp(r'backgroundColor:\s*isDark\s*\?\s*const\s*Color\(0xFF0A0A0A\)\s*:\s*Colors\.white,?');
      if (bgPattern1.hasMatch(content)) {
        content = content.replaceAll(bgPattern1, '''backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
            system: Colors.white.withValues(alpha: 0.1),
          ),
          elevation: themeProvider.isSystemMode ? 0 : null,''');
        changed = true;
      }
      
      final bgPattern2 = RegExp(r'color:\s*isDark\s*\?\s*const\s*Color\(0xFF0A0A0A\)\s*:\s*Colors\.white,?');
      if (bgPattern2.hasMatch(content)) {
        content = content.replaceAll(bgPattern2, '''color: themeProvider.resolveColor(
                      light: Colors.white,
                      dark: const Color(0xFF0A0A0A),
                      system: Colors.white.withValues(alpha: 0.1),
                    ),
                    border: themeProvider.isSystemMode ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,''');
        changed = true;
      }

      if (changed) {
        if (!content.contains("import 'package:mess_manager/providers/theme_provider.dart';")) {
          content = "import 'package:mess_manager/providers/theme_provider.dart';\n" + content;
        }
        if (!content.contains("import 'package:provider/provider.dart';")) {
          content = "import 'package:provider/provider.dart';\n" + content;
        }
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
