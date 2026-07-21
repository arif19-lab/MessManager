import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/theme_transition_wrapper.dart';
import '../l10n/bangla_localizations.dart';

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
              BanglaLocalizations.of(context).settings,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),

            // ── Theme Card (glassy background matching Language card) ──
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.05)]
                            : [Colors.white, const Color(0xFFF1F5F9)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BanglaLocalizations.of(context).appearance,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dual Capsule Switches
                  Row(
                    children: [
                      Expanded(
                        child: _NeumorphicSwitch(
                          isActive: !isDark,
                          isDark: isDark,
                          onTap: () => _triggerThemeTransition(context, themeProvider, false),
                          icon: Icons.wb_sunny_rounded,
                          iconColor: Colors.amber,
                          glowColor: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NeumorphicSwitch(
                          isActive: isDark,
                          isDark: isDark,
                          onTap: () => _triggerThemeTransition(context, themeProvider, true),
                          icon: Icons.nightlight_round,
                          iconColor: const Color(0xFFFFD166),
                          glowColor: const Color(0xFFFFD166),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Light / Dark text buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _triggerThemeTransition(context, themeProvider, false),
                          child: Container(
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D3748) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF0F172A).withValues(alpha: 0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              BanglaLocalizations.of(context).light,
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _triggerThemeTransition(context, themeProvider, true),
                          child: Container(
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D3748) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF0F172A).withValues(alpha: 0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              BanglaLocalizations.of(context).dark,
                              style: TextStyle(
                                color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Language Section ──
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
                            : [Colors.white, const Color(0xFFF1F5F9)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.2) 
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          BanglaLocalizations.of(context).language,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          BanglaLocalizations.of(context).selectLanguage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _LanguageTogglePillMobile(
                                label: 'English',
                                isSelected: !context.watch<LanguageProvider>().isBangla,
                                isDark: isDark,
                                onTap: () {
                                  context.read<LanguageProvider>().setLocale(const Locale('en'));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _LanguageTogglePillMobile(
                                label: 'বাংলা',
                                isSelected: context.watch<LanguageProvider>().isBangla,
                                isDark: isDark,
                                onTap: () {
                                  context.read<LanguageProvider>().setLocale(const Locale('bn', 'BD'));
                                },
                              ),
                            ),
                          ],
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

class _LanguageTogglePillMobile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageTogglePillMobile({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF134E4A) : const Color(0xFF0D9488))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.4)),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[300] : const Color(0xFF475569)),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
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
