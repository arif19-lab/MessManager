import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      
      bool changed = false;
      
      // Inject themeProvider into builder: (context) { bool isDark...
      final builderRegex = RegExp(r'builder:\s*\((.*?)\)\s*\{\s*bool\s*isDark\s*=\s*Theme\.of\((.*?)\)\.brightness\s*==\s*Brightness\.dark;');
      if (builderRegex.hasMatch(content)) {
        content = content.replaceAllMapped(builderRegex, (match) {
          String args = match.group(1)!;
          String ctx = match.group(2)!;
          return '''builder: ($args) {
        final themeProvider = Provider.of<ThemeProvider>($ctx, listen: false);
        bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;''';
        });
        changed = true;
      }
      
      // Replace hardcoded AlertDialog backgroundColor
      final alertBgRegex = RegExp(r'backgroundColor:\s*isDark\s*\?\s*const\s*Color\(0xFF0A0A0A\)\s*:\s*Colors\.white,');
      if (alertBgRegex.hasMatch(content)) {
        content = content.replaceAll(alertBgRegex, '''backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
            system: Colors.white.withValues(alpha: 0.1),
          ),
          elevation: themeProvider.isSystemMode ? 0 : null,''');
        changed = true;
      }
      
      // Replace hardcoded Container color inside dialogs
      final containerColorRegex = RegExp(r'color:\s*isDark\s*\?\s*const\s*Color\(0xFF0A0A0A\)\s*:\s*Colors\.white,');
      if (containerColorRegex.hasMatch(content)) {
        content = content.replaceAll(containerColorRegex, '''color: themeProvider.resolveColor(
                      light: Colors.white,
                      dark: const Color(0xFF0A0A0A),
                      system: Colors.white.withValues(alpha: 0.1),
                    ),
                    border: themeProvider.isSystemMode ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,''');
        changed = true;
      }
      
      if (changed) {
        // Ensure imports
        if (!content.contains("import 'package:mess_manager/providers/theme_provider.dart';")) {
          content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:mess_manager/providers/theme_provider.dart';");
        }
        if (!content.contains("import 'package:provider/provider.dart';")) {
          content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:provider/provider.dart';");
        }
        if (!content.contains("import 'dart:ui' as ui;")) {
          content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:ui' as ui;");
        }
        
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
