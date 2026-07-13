import 'dart:io';

void main() {
  final libDir = Directory('C:/Users/Imran/mess_manager/lib');
  int filesUpdated = 0;

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;

      // 1. Remove imports
      final importsToRemove = [
        "import '../widgets/glassy_notification.dart';",
        "import 'package:mess_manager/widgets/glassy_notification.dart';",
        "import '../widgets/glass_dialog.dart';",
        "import 'package:mess_manager/widgets/glass_dialog.dart';",
        "import '../widgets/glass_panel.dart';",
        "import '../widgets/system_theme_background.dart';"
      ];
      
      for (var imp in importsToRemove) {
        if (content.contains(imp)) {
          content = content.replaceAll(imp + '\\r\\n', '');
          content = content.replaceAll(imp + '\\n', '');
          content = content.replaceAll(imp, '');
          changed = true;
        }
      }

      // 2. Replace showGlassDialog with showDialog
      if (content.contains('showGlassDialog')) {
        content = content.replaceAll('showGlassDialog', 'showDialog');
        changed = true;
      }

      // 3. Replace GlassyNotification.show
      // format: GlassyNotification.show(context: context, title: 'Error', message: e.toString());
      final regex = RegExp(
        r"GlassyNotification\.show\(\s*context:\s*context,\s*title:\s*(.*?),\s*message:\s*(.*?)(?:,\s*)?\);",
        dotAll: true
      );
      
      if (regex.hasMatch(content)) {
        content = content.replaceAllMapped(regex, (match) {
          final message = match.group(2)!.trim();
          return 'ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(\$message)));';
        });
        changed = true;
      }

      if (changed) {
        entity.writeAsStringSync(content);
        print('Cleaned \${entity.path}');
        filesUpdated++;
      }
    }
  }
  print('Total files cleaned: \$filesUpdated');
}
