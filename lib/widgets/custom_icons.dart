import 'package:flutter/material.dart';

/// Place your custom icons here!
/// You can paste raw SVG strings, custom painter classes, or asset paths in this file.
/// We will connect them to the buttons later.
class CustomIcons {
  // Example 1: Custom SVG string placeholder
  static const String customIconSvgPlaceholder = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Paste your SVG XML tags/content here -->
</svg>
''';

  // Example 2: Custom Asset image path
  static const String customIconAssetPath = 'assets/icons/custom_icon.png';

  // Example 3: Custom Widget representation
  static Widget getCustomIcon(BuildContext context) {
    return const Icon(
      Icons.star_rounded,
      color: Colors.amber,
      size: 24,
    ); // Replace this icon with your pasted widget or image when ready
  }
}

