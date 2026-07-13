import re

with open('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove _buildGlassNavBar
content = re.sub(r'Widget _buildGlassNavBar\(\) \{.*?\}\n\n  Widget _buildAnimatedNavBar\(\) \{', 'Widget _buildAnimatedNavBar() {', content, flags=re.DOTALL)

# 2. Remove if (themeProvider.isSystemMode) { return _buildGlassNavBar(); }
content = re.sub(r'    if \(themeProvider\.isSystemMode\) \{\n      return _buildGlassNavBar\(\);\n    \}\n    bool isDark = themeProvider\.isDarkMode;', '    bool isDark = themeProvider.isDarkMode || themeProvider.isSystemMode;', content, flags=re.DOTALL)

# 3. Remove GlassyNotification usages (this requires more care)
content = re.sub(r"GlassyNotification\.show\(context: context, title: (.*?), message: (.*?)\);", r"ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(\2)));", content)
content = re.sub(r"import 'package:mess_manager/widgets/glassy_notification.dart';\n", "", content)

# 4. Remove system: Colors.transparent from main Containers
content = re.sub(r'system: Colors\.transparent,\n              \)', r')', content)
content = re.sub(r'system: Colors\.transparent,\n          \)', r')', content)

with open('C:/Users/Imran/mess_manager/lib/screens/home_screen.dart', 'w') as f:
    f.write(content)
print("home_screen.dart completely reverted.")
