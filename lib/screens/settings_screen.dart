import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_transition_wrapper.dart';
import '../widgets/glassy_theme_switch.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),

            // Authentic Glassmorphic Appearance Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)]
                            : [Colors.white, const Color(0xFFF1F5F9)], // Pristine glossy white for light mode
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.2) 
                            : const Color(0xFFE2E8F0), // Subtle light border
                        width: 1.5,
                      ),
                    ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Side Content
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Elegant Minimal Title
                        Text(
                          'Appearance',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Professional Accent Subtitle
                        Text(
                          'Visual Theme',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description text
                        Text(
                          'Choose your preferred style',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Glassy Appearance Switch
                  GlassyThemeSwitch(
                    themeProvider: themeProvider,
                    onToggle: () => _triggerThemeTransition(context, themeProvider, !isDark),
                  ),
                ],
              ),
            ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}

void _triggerThemeTransition(BuildContext context, ThemeProvider provider, bool isDark) {
  ThemeTransitionController.run(() => provider.setDarkMode(isDark));
}

class NeumorphicTextButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isActive;
  final VoidCallback onTap;

  const NeumorphicTextButton({
    super.key,
    required this.label,
    required this.isDark,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive 
              ? (isDark ? const Color(0xFF134E4A) : const Color(0xFF0F172A))
              : (isDark ? const Color(0xFF2D3748) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive 
                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F172A))
                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF0F172A).withValues(alpha: 0.1)),
            width: 1.2,
          ),
          boxShadow: [
            if (!isActive)
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF0F172A).withValues(alpha: 0.06),
                offset: const Offset(0, 2),
                blurRadius: 0,
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive 
                ? (isDark ? const Color(0xFF2DD4BF) : Colors.white)
                : (isDark ? Colors.grey[300] : const Color(0xFF475569)),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _NeumorphicSwitch extends StatelessWidget {
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;

  const _NeumorphicSwitch({
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF090D16) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 44 : 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242E42) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: isActive
                    ? Text(
                        'On',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? iconColor : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
