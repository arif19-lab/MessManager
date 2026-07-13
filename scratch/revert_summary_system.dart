import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/summary_screen.dart');
  final lines = file.readAsLinesSync();
  
  // Also fix the Scaffold backgroundColor
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('return Scaffold(')) {
      if (i + 1 < lines.length && lines[i+1].contains('backgroundColor: Colors.transparent,')) {
        lines[i+1] = '      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,';
      }
    }
    
    if (lines[i].contains('light:')) {
      // Find dark value in the next line
      if (i + 1 < lines.length && lines[i+1].contains('dark: ')) {
        String darkVal = lines[i+1].split('dark: ')[1].trim();
        // Remove trailing comma
        if (darkVal.endsWith(',')) darkVal = darkVal.substring(0, darkVal.length - 1);
        
        // Find system value in the next line
        if (i + 2 < lines.length && lines[i+2].contains('system: ')) {
          lines[i+2] = lines[i+2].replaceRange(
            lines[i+2].indexOf('system: '), 
            lines[i+2].length, 
            'system: \$darkVal,'
          );
        }
      }
    }
  }
  
  file.writeAsStringSync(lines.join('\\n'));
  print('Updated summary_screen.dart');
}
