import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/summary_screen.dart');
  final lines = file.readAsLinesSync();
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('light:')) {
      // Find dark value in the next few lines
      String darkVal = '';
      for (int j = i + 1; j <= i + 3; j++) {
        if (j < lines.length && lines[j].contains('dark:')) {
          darkVal = lines[j].split('dark:')[1].trim();
          if (darkVal.endsWith(',')) darkVal = darkVal.substring(0, darkVal.length - 1);
          break;
        }
      }
      
      if (darkVal.isNotEmpty) {
        // Find system value in the next few lines
        for (int j = i + 1; j <= i + 4; j++) {
          if (j < lines.length && lines[j].contains('system:')) {
            // Replace the entire line's 'system: ...,' with 'system: \$darkVal,'
            // Since there is a lot of whitespace, we'll preserve everything before 'system:'
            int systemIdx = lines[j].indexOf('system:');
            lines[j] = lines[j].substring(0, systemIdx) + 'system: \$darkVal,';
            break;
          }
        }
      }
    }
  }
  
  file.writeAsStringSync(lines.join('\\n'));
  print('Updated summary_screen.dart fully');
}
