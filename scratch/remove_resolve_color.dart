import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('C:/Users/Imran/mess_manager/lib');
  
  if (!libDir.existsSync()) {
    print('Directory not found');
    return;
  }
  
  final regex = RegExp(
    r'themeProvider\.resolveColor\s*\(\s*light:\s*(.*?),\s*dark:\s*(.*?),\s*system:\s*(.*?),\s*\)',
    dotAll: true,
  );

  int totalReplaced = 0;

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('theme_provider.dart')) {
      String content = entity.readAsStringSync();
      
      if (content.contains('resolveColor')) {
        content = content.replaceAllMapped(regex, (match) {
          final light = match.group(1)?.trim();
          final dark = match.group(2)?.trim();
          // We completely ignore the system color (group 3)
          return '(themeProvider.isDarkMode ? \$dark : \$light)';
        });
        
        // Also catch cases where trailing comma might be missing
        final regexNoComma = RegExp(
          r'themeProvider\.resolveColor\s*\(\s*light:\s*(.*?),\s*dark:\s*(.*?),\s*system:\s*(.*?)\s*\)',
          dotAll: true,
        );
        content = content.replaceAllMapped(regexNoComma, (match) {
          final light = match.group(1)?.trim();
          final dark = match.group(2)?.trim();
          return '(themeProvider.isDarkMode ? \$dark : \$light)';
        });
        
        entity.writeAsStringSync(content);
        print('Updated \${p.basename(entity.path)}');
        totalReplaced++;
      }
    }
  }
  print('Total files updated: \$totalReplaced');
}
