import 'package:flutter/material.dart';

/// ModernThemeIcon: Displays the user's custom Sun and Moon icons from assets/icons/
/// with smooth theme-aware tinting and transition.
class ModernThemeIcon extends StatelessWidget {
  final bool isDark;
  final double size;
  final Color? color;

  const ModernThemeIcon({
    super.key,
    required this.isDark,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // In dark theme: tint white so it's clear on dark background.
    // In light theme: tint dark slate so it's clear on light background.
    final iconColor = color ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    // When dark, button offers to switch to light (sun).
    // When light, button offers to switch to dark (moon).
    final assetPath = isDark ? 'assets/icons/sun.png' : 'assets/icons/moon.png';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: Tween<double>(begin: 0.88, end: 1.0).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.80, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Image.asset(
        assetPath,
        key: ValueKey(isDark),
        width: size,
        height: size,
        color: iconColor,
        fit: BoxFit.contain,
      ),
    );
  }
}
