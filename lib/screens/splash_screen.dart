import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mess_provider.dart';
import '../services/auth_mode_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final provider = context.read<MessProvider>();
    await provider.initialize();
    if (!mounted) return;
    final isLoggedIn = await AuthModeService.getIsLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => isLoggedIn ? const HomeScreen() : const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.black, const Color(0xFF1E293B)]
                : [const Color(0xFFF9FAFB), const Color(0xFFE2E8F0)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mess Manager',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Loading your data...',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: const Color(0xFF0D9488),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

