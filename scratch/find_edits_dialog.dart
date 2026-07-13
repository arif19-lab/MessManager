import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  int totalReplaced = 0;
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      
      if (!content.contains('showDialog(')) continue;
      
      print('Processing ${entity.path}');
      
      // Need to make sure import 'dart:ui' as ui; is there
      if (!content.contains("import 'dart:ui' as ui;")) {
        content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:ui' as ui;");
      }
      if (!content.contains("import 'package:mess_manager/providers/theme_provider.dart';")) {
        content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:mess_manager/providers/theme_provider.dart';");
      }
      
      // 1. Replace builder: (context) { \n bool isDark... with the themeProvider logic and BackdropFilter
      // Note: Because formatting might vary, we'll use regex.
      
      content = content.replaceAllMapped(
        RegExp(r'builder:\s*\((.*?)\)\s*\{\s*bool\s*isDark\s*=\s*Theme\.of\((.*?)\)\.brightness\s*==\s*Brightness\.dark;'),
        (match) {
          String args = match.group(1)!;
          String ctx = match.group(2)!;
          return '''builder: ($args) {
        final themeProvider = Provider.of<ThemeProvider>($ctx, listen: false);
        bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;''';
        }
      );
      
      // 2. Replace return AlertDialog(...) with BackdropFilter(child: AlertDialog(...))
      content = content.replaceAllMapped(
        RegExp(r'return\s+AlertDialog\('),
        (match) {
          return '''return BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: themeProvider.isSystemMode ? 16.0 : 0.0,
            sigmaY: themeProvider.isSystemMode ? 16.0 : 0.0,
          ),
          child: AlertDialog(''';
        }
      );
      
      // Also close the BackdropFilter if we replaced AlertDialog. 
      // But wait! If we just replace `return AlertDialog(`, we have to close the `)` of BackdropFilter!
      // This is too hard to do with simple RegExp because of nested parentheses.
      
    }
  }
}
