import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart');
  String content = file.readAsStringSync();
  
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
      print('--- BLOCK START ---');
      print(block);
      print('--- BLOCK END ---');
      index = closeParen + 1;
    } else {
      index += 1;
    }
  }
}
