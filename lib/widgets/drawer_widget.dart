import 'dart:io';
import 'dart:ui';
import '../l10n/bangla_localizations.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mess_provider.dart';

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
    
    double drawerWidth = isDesktop ? 280 : (screenWidth * 0.85).clamp(0, 400).toDouble();
    
    // Safe area padding — iOS Dynamic Island / Notch auto-adjust
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.only(
          top: (topPadding + 16).clamp(40.0, double.infinity),
          bottom: (bottomPadding + 24).clamp(40.0, double.infinity),
          left: 16,
        ),
        decoration: BoxDecoration(
          color: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(48)),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader(bn.drawerMenu),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22).withValues(alpha: 0.15) : const Color(0xFFE2E8F0).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                      boxShadow: const [],
                    ),
                    child: Column(
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
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader(bn.drawerOptions),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22).withValues(alpha: 0.15) : const Color(0xFFE2E8F0).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                      boxShadow: const [],
                    ),
                    child: Column(
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
                  ),
                ],
              ),
            ),
            // Footer Version
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                bn.versionLabel,
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    bool isDesktop = MediaQuery.of(context).size.width > 850;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 56, right: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22).withValues(alpha: 0.15) : const Color(0xFFE2E8F0).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
              boxShadow: const [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<MessProvider>(
                  builder: (context, provider, _) {
                    return GestureDetector(
                      onTap: () {
                        provider.pickCustomAvatar();
                      },
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: isDark ? const Color(0xFF242E42) : Colors.white,
                        child: ClipOval(
                          child: provider.customAvatarPath != null
                              ? Image.file(
                                  File(provider.customAvatarPath!),
                                  fit: BoxFit.cover,
                                  width: 44,
                                  height: 44,
                                )
                              : Image.asset(
                                  'assets/icons/avatar.png',
                                  color: isDark ? Colors.white : null,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    );
                  }
                ),
                const Spacer(),
                 GestureDetector(
                   onTap: () {
                     onClose?.call();
                   },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242E42) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.06),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -1.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
                  width: 1.5,
                ),
              ),
              child: Text(
                BanglaLocalizations.of(context).appTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0D9488), // Teal/Green header color matching the image
          fontWeight: FontWeight.w900,
          fontSize: 13.5,
          letterSpacing: 0.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.35)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 10),
            imageAssetPath != null
                ? Image.asset(
                    imageAssetPath,
                    width: 22,
                    height: 22,
                    filterQuality: FilterQuality.high,
                    color: isDark ? Colors.white : null,
                  )
                : Icon(
                    icon,
                    color: isDark ? Colors.white : const Color(0xFF374151),
                    size: 22,
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
