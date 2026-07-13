import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('C:/Users/Imran/mess_manager/lib');
  
  if (!libDir.existsSync()) {
    print('Directory not found');
    return;
  }

  int totalReplaced = 0;

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('theme_provider.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;
      
      // Look for themeProvider.resolveColor(
      // We will just do a simple string matching algorithm to find light: and dark: and replace the whole block
      int index = 0;
      while ((index = content.indexOf('themeProvider.resolveColor(', index)) != -1) {
        int openParen = index + 'themeProvider.resolveColor'.length;
        // Find matching closing paren
        int closeParen = -1;
        int parens = 0;
        for (int i = openParen; i < content.length; i++) {
          if (content[i] == '(') parens++;
          if (content[i] == ')') {
            parens--;
            if (parens == 0) {
              closeParen = i;
              break;
            }
          }
        }
        
        if (closeParen != -1) {
          String block = content.substring(openParen + 1, closeParen);
          
          String light = '';
          String dark = '';
          
          final lightMatch = RegExp(r'light:\s*(.+?)(?:,\s*dark:|$)', dotAll: true).firstMatch(block);
          if (lightMatch != null) {
            light = lightMatch.group(1)!.trim();
            if (light.endsWith(',')) light = light.substring(0, light.length - 1);
          }
          
          final darkMatch = RegExp(r'dark:\s*(.+?)(?:,\s*system:|$)', dotAll: true).firstMatch(block);
          if (darkMatch != null) {
            dark = darkMatch.group(1)!.trim();
            if (dark.endsWith(',')) dark = dark.substring(0, dark.length - 1);
          }
          
          // If system was removed, dark might have a trailing comma
          if (dark.endsWith(',')) dark = dark.substring(0, dark.length - 1);
          
          if (light.isNotEmpty && dark.isNotEmpty) {
            String replacement = '(themeProvider.isDarkMode ? \$dark : \$light)';
            content = content.replaceRange(index, closeParen + 1, replacement);
            changed = true;
          } else {
            index = closeParen + 1; // Move past if we couldn't parse it
          }
        } else {
          index += 1;
        }
      }
      
      if (changed) {
        entity.writeAsStringSync(content);
        print('Updated \${p.basename(entity.path)}');
        totalReplaced++;
      }
    }
  }
  print('Total files updated: \$totalReplaced');
}
