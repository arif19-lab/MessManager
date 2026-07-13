import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart');
  List<String> lines = file.readAsLinesSync();
  List<String> newLines = [];
  
  bool insideGlassNavBar = false;
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildGlassNavBar() {')) {
      insideGlassNavBar = true;
    }
    
    if (insideGlassNavBar) {
      if (lines[i].trim() == '}' && i < lines.length - 1 && lines[i+1].trim() == '' && lines[i+2].contains('Widget _buildAnimatedNavBar() {')) {
        insideGlassNavBar = false;
      } else if (lines[i].trim() == '}' && i < lines.length - 2 && lines[i+2].contains('Widget _buildAnimatedNavBar() {')) {
        insideGlassNavBar = false;
      }
      continue;
    }
    
    if (lines[i].contains('if (themeProvider.isSystemMode) {')) {
      if (i + 1 < lines.length && lines[i+1].contains('return _buildGlassNavBar();')) {
        // Skip these three lines: if, return, }
        i += 2;
        continue;
      }
    }
    
    if (lines[i].contains('bool isDark = themeProvider.isDarkMode;')) {
      newLines.add('    bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;');
      continue;
    }
    
    newLines.add(lines[i]);
  }
  
  file.writeAsStringSync(newLines.join('\\n'));
  print('home_screen.dart nav bar reverted.');
}
