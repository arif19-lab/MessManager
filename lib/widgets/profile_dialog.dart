import 'dart:io';
import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mess_provider.dart';
import '../services/firebase_service.dart';
import '../services/auth_mode_service.dart';
import '../services/google_sign_in_desktop.dart';
import '../screens/login_screen.dart';

class ProfileDialog extends StatefulWidget {
  final Animation<double>? animation;
  final bool isMobile;
  const ProfileDialog({super.key, this.animation, this.isMobile = false});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'ProfileDialog',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
        );
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth <= 850;
        final topPosition = isMobile ? 120.0 : 102.0;
        return Stack(
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final opacity = animation.status == AnimationStatus.reverse
                    ? (animation.value > 0.1 ? 1.0 : animation.value / 0.1)
                    : animation.value;
                if (opacity < 0.01) return const SizedBox.shrink();
                final targetAlpha = isMobile ? 0.8 : 0.45; // Soft-medium dim on desktop
                return Container(
                  color: Colors.black.withValues(alpha: targetAlpha * opacity),
                );
              },
            ),
            Positioned(
              top: topPosition,
              right: 16,
              child: ProfileDialog(animation: curvedAnimation, isMobile: isMobile),
            ),
          ],
        );
      },
    );
  }

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  String _authMode = 'offline';

  @override
  void initState() {
    super.initState();
    _loadAuthMode();
  }

  Future<void> _loadAuthMode() async {
    final mode = await AuthModeService.getMode();
    if (mounted) setState(() => _authMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessProvider>(context);
    final user = provider.currentUser;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final anim = widget.animation;

    return Material(
      type: MaterialType.transparency,
      child: FadeTransition(
        opacity: anim ?? const AlwaysStoppedAnimation(1),
        child: Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF94A3B8).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: ClipPath(
            clipper: _ShutterClipper(28.0),
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: anim?.value ?? 1,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.isMobile ? 300 : 250),
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 36,
                        spreadRadius: 1,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeProvider.resolveColor(
                          light: Colors.white,
                          dark: const Color(0xFF0A0A0A),
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('WELCOME', style: GoogleFonts.pressStart2p(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 8, letterSpacing: 0.5)),
                                    const SizedBox(height: 4),
                                    Text('BACK', style: GoogleFonts.pressStart2p(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    Container(width: 32, height: 4, decoration: BoxDecoration(color: const Color(0xFF0D9488), borderRadius: BorderRadius.circular(4))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () { provider.pickCustomAvatar(); },
                                      child: ProfileAvatar(radius: 34, customAvatarPath: provider.customAvatarPath),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(user.name.toUpperCase(), style: GoogleFonts.pressStart2p(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                    const SizedBox(height: 4),
                                    Text('ADMIN', style: GoogleFonts.pressStart2p(color: const Color(0xFF0D9488), fontSize: 6, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05), width: 1.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Icon(Icons.email_outlined, color: isDark ? Colors.grey[400] : const Color(0xFF64748B), size: 14),
                                    const SizedBox(width: 8),
                                    Text('EMAIL ADDRESS', style: GoogleFonts.pressStart2p(color: isDark ? Colors.grey[400] : const Color(0xFF64748B), fontSize: 6, fontWeight: FontWeight.bold)),
                                  ]),
                                  const SizedBox(height: 6),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(user.email.toUpperCase(), style: GoogleFonts.pressStart2p(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 7)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: _authMode == 'google' ? _buildLogoutButton() : _buildLoginButton()),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D9488),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF0D9488), width: 1.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('CLOSE', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8)),
                                        ],
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final nav = Navigator.of(context);
    return InkWell(
      onTap: () async {
        await FirebaseService().signOut();
        await AuthModeService.logout();
        if (mounted) {
          await context.read<MessProvider>().initialize();
          if (mounted) {
            nav.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D9488),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D9488), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text('LOGOUT', overflow: TextOverflow.ellipsis, style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return InkWell(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D9488), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login_rounded, size: 16, color: Color(0xFF0F766E)),
            const SizedBox(width: 8),
            Flexible(child: Text('LOGIN', overflow: TextOverflow.ellipsis, style: GoogleFonts.pressStart2p(color: const Color(0xFF0F766E), fontSize: 8))),
          ],
        ),
      ),
    );
  }
}

class _ShutterClipper extends CustomClipper<Path> {
  final double cornerRadius;
  _ShutterClipper(this.cornerRadius);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(cornerRadius),
      ));
  }

  @override
  bool shouldReclip(_ShutterClipper oldClipper) => oldClipper.cornerRadius != cornerRadius;
}

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final String? customAvatarPath;

  const ProfileAvatar({
    super.key,
    required this.radius,
    this.customAvatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ClipOval(
        child: customAvatarPath != null
            ? Image.file(File(customAvatarPath!), fit: BoxFit.cover, width: size, height: size)
            : Image.asset('assets/icons/avatar.png', fit: BoxFit.cover, width: size, height: size, color: const Color(0xFF1E293B)),
      ),
    );
  }
}
