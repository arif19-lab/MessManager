import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final dir = Directory('C:/Users/Imran/mess_manager/lib/screens');
  
  if (!dir.existsSync()) {
    print('Directory not found');
    return;
  }
  
  for (final entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      bool changed = false;
      List<String> lines = entity.readAsLinesSync();
      
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('showGlassDialog')) {
          lines[i] = lines[i].replaceAll('showGlassDialog', 'showDialog');
          changed = true;
        }
        if (lines[i].contains('import \'../widgets/glass_dialog.dart\';')) {
          lines[i] = lines[i].replaceAll('import \'../widgets/glass_dialog.dart\';', '');
          changed = true;
        }
        if (lines[i].contains('import \'package:mess_manager/widgets/glass_dialog.dart\';')) {
          lines[i] = lines[i].replaceAll('import \'package:mess_manager/widgets/glass_dialog.dart\';', '');
          changed = true;
        }
      }
      
      if (changed) {
        entity.writeAsStringSync(lines.join('\\n'));
        print('Updated \${p.basename(entity.path)}');
      }
    }
  }
  print('All screen files processed.');
}
