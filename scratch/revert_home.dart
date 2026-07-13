import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart');
  String content = file.readAsStringSync();

  // 1. Remove _buildGlassNavBar
  final RegExp buildGlassNavBarRegex = RegExp(r'Widget _buildGlassNavBar\(\) \{.*?\n\n  Widget _buildAnimatedNavBar\(\) \{', dotAll: true);
  content = content.replaceAll(buildGlassNavBarRegex, 'Widget _buildAnimatedNavBar() {');

  // 2. Remove if (themeProvider.isSystemMode) { return _buildGlassNavBar(); }
  final RegExp systemModeRegex = RegExp(r'    if \(themeProvider\.isSystemMode\) \{\s*return _buildGlassNavBar\(\);\s*\}\s*bool isDark = themeProvider\.isDarkMode;', dotAll: true);
  content = content.replaceAll(systemModeRegex, '    bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;');

  // 3. Remove GlassyNotification usages (this requires more care)
  final RegExp glassyNotifRegex = RegExp(r"GlassyNotification\.show\(context: context, title: (.*?), message: (.*?)\);");
  content = content.replaceAllMapped(glassyNotifRegex, (match) {
    return 'ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(\${match.group(2)})));';
  });
  content = content.replaceAll("import 'package:mess_manager/widgets/glassy_notification.dart';\n", "");

  // 4. Remove system: Colors.transparent from main Containers
  content = content.replaceAll('system: Colors.transparent,\n              )', ')');
  content = content.replaceAll('system: Colors.transparent,\n          )', ')');

  file.writeAsStringSync(content);
  print('home_screen.dart completely reverted.');
}
