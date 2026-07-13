import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;
      
      // 1. Replace showDialog( with showGlassDialog(
      if (content.contains('showDialog(')) {
        content = content.replaceAll('showDialog(', 'showGlassDialog(');
        changed = true;
      }
      
      // 2. Increase the opacity of the glass tint for readability
      String oldSystemBg = "system: Colors.white.withValues(alpha: 0.1),";
      String newSystemBg = "system: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.7),";
      if (content.contains(oldSystemBg)) {
        content = content.replaceAll(oldSystemBg, newSystemBg);
        changed = true;
      }
      
      // Add imports if needed
      if (changed) {
        if (!content.contains("import '../widgets/glass_dialog.dart';")) {
          // Find the last import and insert after it
          int lastImport = content.lastIndexOf('import ');
          if (lastImport != -1) {
            int nextLine = content.indexOf('\\n', lastImport);
            if (nextLine != -1) {
              content = content.substring(0, nextLine + 1) + "import '../widgets/glass_dialog.dart';\n" + content.substring(nextLine + 1);
            } else {
               content = "import '../widgets/glass_dialog.dart';\n" + content;
            }
          } else {
             content = "import '../widgets/glass_dialog.dart';\n" + content;
          }
        }
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
