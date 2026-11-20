import 'dart:io';
import 'dart:ui';
import '../l10n/bangla_localizations.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mess_provider.dart';
import '../providers/language_provider.dart';

class DrawerWidget extends StatelessWidget {
  final int activeIndex;
  final Function(int)? onItemTapped;
  final VoidCallback? onClose;

  const DrawerWidget({
    super.key,
    this.activeIndex = 0,
    this.onItemTapped,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bn = BanglaLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    
    double drawerWidth = isDesktop ? 280 : (screenWidth * 0.78).clamp(250.0, 320.0).toDouble();

    const borderRadius = BorderRadius.only(
      topRight: Radius.circular(28.0),
      bottomRight: Radius.circular(28.0),
    );

    return SizedBox(
      width: drawerWidth,
      height: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: Container(
            decoration: BoxDecoration(
              // Translucent Crystal Frosted Glass: lets main screen show through faintly
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0x16FFFFFF), // Top subtle luminous sheen
                        const Color(0x0CFFFFFF), // Translucent frosted body
                        const Color(0x08FFFFFF), // Bottom subtle tone
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.50),
                        Colors.white.withValues(alpha: 0.38),
                        Colors.white.withValues(alpha: 0.28),
                      ],
              ),
              border: Border.all(
                color: isDark ? const Color(0x35FFFFFF) : const Color(0x28000000),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(6, 0),
                ),
              ],
            ),
            child: SafeArea(
              top: true,
              bottom: true,
              child: Stack(
                children: [
                  // Main drawer content
                  Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 2),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildSectionHeader(bn.drawerMenu, isDark),
                            _buildGlassSectionContainer(
                              isDark: isDark,
                              children: [
                                _buildDrawerItem(
                                  index: 3,
                                  icon: Icons.shopping_cart_outlined,
                                  imageAssetPath: 'assets/icons/expenses.png',
                                  title: bn.drawerExpenses,
                                  context: context,
                                  activeColor: const Color(0xFFF59E0B),
                                ),
                                const SizedBox(height: 4),
                                _buildDrawerItem(
                                  index: 4,
                                  icon: Icons.phone_android_outlined,
                                  imageAssetPath: 'assets/icons/payments.png',
                                  title: bn.drawerPayments,
                                  context: context,
                                  activeColor: const Color(0xFF3B82F6),
                                ),
                                const SizedBox(height: 4),
                                _buildDrawerItem(
                                  index: 5,
                                  icon: Icons.gavel_rounded,
                                  title: bn.drawerFeastFines,
                                  context: context,
                                  activeColor: const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            _buildSectionHeader(bn.drawerOptions, isDark),
                            _buildGlassSectionContainer(
                              isDark: isDark,
                              children: [
                                _buildDrawerItem(
                                  index: 6,
                                  icon: Icons.description_outlined,
                                  imageAssetPath: 'assets/icons/report.png',
                                  title: bn.drawerReports,
                                  context: context,
                                  activeColor: const Color(0xFF0D9488),
                                ),
                                const SizedBox(height: 4),
                                _buildDrawerItem(
                                  index: 7,
                                  icon: Icons.notifications_none_outlined,
                                  imageAssetPath: 'assets/icons/notification.png',
                                  title: bn.drawerNotifications,
                                  context: context,
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                                const SizedBox(height: 4),
                                _buildDrawerItem(
                                  index: 9,
                                  icon: Icons.palette_outlined,
                                  imageAssetPath: 'assets/icons/customize-home.png',
                                  title: bn.drawerCustomizeHome,
                                  context: context,
                                  activeColor: const Color(0xFFEC4899),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      // ── Bottom Action Row HUD (Language & Settings) ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark ? const Color(0x10FFFFFF) : Colors.white.withValues(alpha: 0.40),
                            border: Border.all(
                              color: isDark ? const Color(0x28FFFFFF) : const Color(0x20000000),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Language Toggle Button
                              Consumer<LanguageProvider>(
                                builder: (context, langProvider, _) {
                                  final isBn = langProvider.isBangla;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      langProvider.setLocale(
                                        isBn ? const Locale('en') : const Locale('bn', 'BD'),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: isDark ? const Color(0x18FFFFFF) : Colors.white.withValues(alpha: 0.70),
                                        border: Border.all(
                                          color: isDark ? const Color(0x35FFFFFF) : const Color(0x22000000),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.translate_rounded,
                                            size: 16,
                                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isBn ? 'বাংলা' : 'English',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const Spacer(),

                              // Settings Navigation Button
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  onClose?.call();
                                  onItemTapped?.call(8);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isDark ? const Color(0x18FFFFFF) : Colors.white.withValues(alpha: 0.70),
                                    border: Border.all(
                                      color: isDark ? const Color(0x35FFFFFF) : const Color(0x22000000),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.settings_outlined,
                                        size: 16,
                                        color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        bn.settings,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Footer Version
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 2),
                        child: Text(
                          bn.versionLabel,
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
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
    ),
  );
  }

  Widget _buildGlassSectionContainer({
    required bool isDark,
    required List<Widget> children,
  }) {
    // ── Double-Layer Blur Glass Architecture (Crystal Translucent Liquid Glass) ──
    // Layer 1: Base Translucent Glass Tray
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: isDark ? const Color(0x08FFFFFF) : Colors.white.withValues(alpha: 0.18),
          border: Border.all(
            color: isDark ? const Color(0x28FFFFFF) : const Color(0x20000000),
            width: 1.1,
          ),
        ),
        padding: const EdgeInsets.all(5.0), // Floating elevation margin
        // Layer 2: Elevated Floating Liquid Glass Plate (lets main screen show through faintly)
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: isDark ? const Color(0x12FFFFFF) : Colors.white.withValues(alpha: 0.30),
              border: Border.all(
                color: isDark ? const Color(0x38FFFFFF) : const Color(0x28000000),
                width: 1.1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 3.0, bottom: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            color: isDark ? const Color(0x08FFFFFF) : Colors.white.withValues(alpha: 0.18),
            border: Border.all(
              color: isDark ? const Color(0x28FFFFFF) : const Color(0x20000000),
              width: 1.1,
            ),
          ),
          padding: const EdgeInsets.all(5.0),
          // Header Floating Surface Glass Plate (Layer 2)
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 12, top: 10, right: 12, bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: isDark ? const Color(0x12FFFFFF) : Colors.white.withValues(alpha: 0.30),
                border: Border.all(
                  color: isDark ? const Color(0x38FFFFFF) : const Color(0x28000000),
                  width: 1.1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Consumer<MessProvider>(
                        builder: (context, provider, _) {
                          return GestureDetector(
                            onTap: () {
                              provider.pickCustomAvatar();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0x60FFFFFF) : const Color(0x2E000000),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: isDark ? const Color(0xFF1E2638) : Colors.white,
                                child: ClipOval(
                                  child: provider.customAvatarPath != null
                                      ? Image.file(
                                          File(provider.customAvatarPath!),
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                        )
                                      : Image.asset(
                                          'assets/icons/avatar.png',
                                          color: isDark ? Colors.white : null,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          onClose?.call();
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x28FFFFFF) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0x35FFFFFF) : const Color(0x2A000000),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // App Name Title Pill (Seamlessly integrated inside HUD)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x18FFFFFF) : Colors.white.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0x35FFFFFF) : const Color(0x2E000000),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          BanglaLocalizations.of(context).appTitle,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, left: 6, right: 4),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
    required BuildContext context,
    String? imageAssetPath,
    Color activeColor = Colors.teal,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    bool isActive = activeIndex == index;

    return InkWell(
      onTap: () {
        onClose?.call(); // Close the custom drawer via callback
        onItemTapped?.call(index);
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                  ? activeColor.withValues(alpha: 0.18)
                  : activeColor.withValues(alpha: 0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: isDark ? 0.55 : 0.4)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 20 : 0,
              margin: EdgeInsets.only(right: isActive ? 10 : 0),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            imageAssetPath != null
                ? Image.asset(
                    imageAssetPath,
                    width: 22,
                    height: 22,
                    filterQuality: FilterQuality.high,
                    color: isActive
                        ? activeColor
                        : (isDark ? Colors.white : null),
                  )
                : Icon(
                    icon,
                    color: isActive
                        ? activeColor
                        : (isDark ? Colors.white : const Color(0xFF374151)),
                    size: 22,
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (isActive)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: activeColor.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }
}
