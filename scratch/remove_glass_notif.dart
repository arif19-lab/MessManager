import 'dart:io';

void main() {
  final file = File('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart');
  List<String> lines = file.readAsLinesSync();
  List<String> newLines = [];
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("import 'package:mess_manager/widgets/glassy_notification.dart';")) {
      continue;
    }
    
    if (lines[i].contains('GlassyNotification.show(')) {
      // It's multiline in some places, so we handle a specific match
      // We will just do a simple string replacement for the entire file at the end
    }
  }
  
  String content = lines.join('\\n');
  content = content.replaceAll("import 'package:mess_manager/widgets/glassy_notification.dart';\\n", "");
  
  // Replace GlassyNotification.show(context: context, title: '...', message: '...');
  // This is a bit tricky with multiline. Let's just use RegExp.
  final RegExp regex = RegExp(r"GlassyNotification\.show\(\s*context:\s*context,\s*title:\s*(.*?),\s*message:\s*(.*?),\s*\);", dotAll: true);
  content = content.replaceAllMapped(regex, (match) {
    return 'ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(\${match.group(2)})));';
  });
  
  // There's also one without trailing comma maybe
  final RegExp regex2 = RegExp(r"GlassyNotification\.show\(\s*context:\s*context,\s*title:\s*(.*?),\s*message:\s*(.*?)\s*\);", dotAll: true);
  content = content.replaceAllMapped(regex2, (match) {
    return 'ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(\${match.group(2)})));';
  });
  
  file.writeAsStringSync(content);
  print('GlassyNotification removed.');
}
