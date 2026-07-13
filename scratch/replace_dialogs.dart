import 'dart:io';

void main() {
  final directory = Directory(r'C:\Users\Imran\mess_manager\lib\screens');
  
  for (var entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      
      if (content.contains('return AlertDialog(')) {
        if (!content.contains('import \'dart:ui\'') && !content.contains('import \'dart:ui\' as ui;')) {
          content = content.replaceFirst(
            "import 'package:flutter/material.dart';", 
            "import 'package:flutter/material.dart';\nimport 'dart:ui' as ui;"
          );
        }
        
        String output = "";
        int currIdx = 0;
        
        while (true) {
          int idx = content.indexOf('return AlertDialog(', currIdx);
          if (idx == -1) {
            output += content.substring(currIdx);
            break;
          }
          
          output += content.substring(currIdx, idx);
          output += 'return BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0), child: AlertDialog(';
          
          int startParen = idx + 'return AlertDialog'.length;
          int openCount = 1;
          int i = startParen + 1;
          
          while (i < content.length) {
            if (content[i] == '(') {
              openCount++;
            } else if (content[i] == ')') {
              openCount--;
              if (openCount == 0) {
                break;
              }
            }
            i++;
          }
          
          output += content.substring(startParen + 1, i);
          output += '))'; // close AlertDialog and BackdropFilter
          
          currIdx = i + 1;
        }
        
        // Also replace background colors
        output = output.replaceAll(
          "backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,",
          "backgroundColor: themeProvider.resolveColor(light: Colors.white, dark: const Color(0xFF0A0A0A), system: Colors.white.withValues(alpha: 0.1)), elevation: 0,"
        );
        
        entity.writeAsStringSync(output);
        print("Updated \${entity.path}");
      }
    }
  }
}
