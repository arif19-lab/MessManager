import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart');
  String content = file.readAsStringSync();
  bool changed = false;
  
  int index = 0;
  while ((index = content.indexOf('themeProvider.resolveColor(', index)) != -1) {
    int openParen = index + 'themeProvider.resolveColor'.length;
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
      
      // Since block contains light: X, dark: Y, [system: Z]
      // We can just find the index of 'light:', 'dark:', and optionally 'system:'
      int lightIdx = block.indexOf('light:');
      int darkIdx = block.indexOf('dark:');
      int systemIdx = block.indexOf('system:');
      
      if (lightIdx != -1 && darkIdx != -1) {
        String lightStr = block.substring(lightIdx + 6, darkIdx).trim();
        if (lightStr.endsWith(',')) lightStr = lightStr.substring(0, lightStr.length - 1).trim();
        
        String darkStr = '';
        if (systemIdx != -1) {
           darkStr = block.substring(darkIdx + 5, systemIdx).trim();
        } else {
           darkStr = block.substring(darkIdx + 5).trim();
        }
        if (darkStr.endsWith(',')) darkStr = darkStr.substring(0, darkStr.length - 1).trim();
        
        String replacement = '(themeProvider.isDarkMode ? \$darkStr : \$lightStr)';
        content = content.replaceRange(index, closeParen + 1, replacement);
        changed = true;
      } else {
        index = closeParen + 1;
      }
    } else {
      index += 1;
    }
  }
  
  if (changed) {
    file.writeAsStringSync(content);
    print('Updated home_screen.dart');
  } else {
    print('No changes made.');
  }
}
