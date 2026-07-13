import 'dart:io';

void main() {
  final directory = Directory('lib/screens');
  final widgetsDir = Directory('lib/widgets');
  
  final List<File> files = [];
  
  for (var dir in [directory, widgetsDir]) {
    for (var entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        files.add(entity);
      }
    }
  }

  for (var file in files) {
    if (file.path.contains('home_screen.dart') || 
        file.path.contains('settings_screen.dart') || 
        file.path.contains('dashboard_card.dart') ||
        file.path.contains('system_theme_background.dart')) {
      continue;
    }

    String content = file.readAsStringSync();
    bool modified = false;

    // Check if we need to add the import
    if (content.contains('Theme.of(context).brightness == Brightness.dark') || 
        content.contains('isDark') ||
        content.contains('ScaffoldBackgroundColor')) {
      
      if (!content.contains('import \'../providers/theme_provider.dart\';') &&
          !content.contains('import \'package:mess_manager/providers/theme_provider.dart\';')) {
        // Simple heuristic to inject import at the top
        content = content.replaceFirst('import \'package:flutter/material.dart\';', 'import \'package:flutter/material.dart\';\nimport \'package:provider/provider.dart\';\nimport \'../providers/theme_provider.dart\';');
        modified = true;
      }
    }

    // Replace binary theme checks
    // We want to replace `bool isDark = Theme.of(context).brightness == Brightness.dark;`
    // with `final themeProvider = Provider.of<ThemeProvider>(context); bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;`
    if (content.contains('bool isDark = Theme.of(context).brightness == Brightness.dark;')) {
      content = content.replaceAll(
          'bool isDark = Theme.of(context).brightness == Brightness.dark;',
          'final themeProvider = Provider.of<ThemeProvider>(context);\n    bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;');
      modified = true;
    } else if (content.contains('final isDark = Theme.of(context).brightness == Brightness.dark;')) {
      content = content.replaceAll(
          'final isDark = Theme.of(context).brightness == Brightness.dark;',
          'final themeProvider = Provider.of<ThemeProvider>(context);\n    final isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;');
      modified = true;
    }
    
    // Some widgets use `Theme.of(context).brightness == Brightness.dark` inline
    if (content.contains('Theme.of(context).brightness == Brightness.dark')) {
      content = content.replaceAll(
          'Theme.of(context).brightness == Brightness.dark',
          '(Provider.of<ThemeProvider>(context).isDarkMode || Provider.of<ThemeProvider>(context).isSystemMode)');
      modified = true;
    }

    // For Scaffolds: `backgroundColor: Theme.of(context).scaffoldBackgroundColor`
    // We want to ensure Scaffolds are transparent in system mode if possible, but actually `ThemeProvider` resolves this if we use resolveColor.
    // To make it easy, we will just use a regex for Scaffold background.
    // A simpler way: Find `backgroundColor: Colors.transparent`... it's already there in some places.
    // Let's just write the changes manually for complex layouts. The script will just do the heavy lifting of `isDark` boolean.
    
    if (modified) {
      file.writeAsStringSync(content);
      print('Modified: ${file.path}');
    }
  }
}
