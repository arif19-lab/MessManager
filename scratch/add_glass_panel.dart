import 'dart:io';

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;
      
      // 1. Add GlassPanel import
      if (content.contains('themeProvider.resolveColor(') && !content.contains("import '../widgets/glass_panel.dart';")) {
        content = "import '../widgets/glass_panel.dart';\n" + content;
        changed = true;
      }
      
      // 2. Wrap AlertDialog( with GlassPanel(isSystemMode: themeProvider.isSystemMode, borderRadius: 20, child: AlertDialog(
      // But only if it's returning AlertDialog
      content = content.replaceAll(
        'return AlertDialog(', 
        'return GlassPanel(isSystemMode: themeProvider.isSystemMode, borderRadius: 20, child: AlertDialog('
      );
      
      // We must close the GlassPanel parenthesis.
      // Every return AlertDialog(...); ends with );
      // However, we can just replace 'actions: [' to something else? No.
      // A better way is: change `showDialog` to use `showGeneralDialog`? No, that's complex.
      // Let's use a regex to find the end of the `AlertDialog`? Very hard in Dart.
      
      if (changed) {
        entity.writeAsStringSync(content);
        print('Updated \${entity.path}');
      }
    }
  }
}
