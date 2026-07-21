import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'home_screen.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';
import 'package:mess_manager/widgets/glass_dialog.dart';
import 'package:mess_manager/providers/mess_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mess_manager/services/firebase_service.dart';
import 'package:mess_manager/services/google_sign_in_desktop.dart';
import 'package:mess_manager/services/auth_mode_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignUp = false;

  bool get _googleSupported => true;
  final _secureStorage = const FlutterSecureStorage();
  List<Map<String, String>> _savedAccounts = [];
  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _loadSavedAccounts();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        GlassyNotification.show(context, message: 'Please enter your email and password.', isError: true);
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await FirebaseService().signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
        );
      } else {
        await FirebaseService().signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      await AuthModeService.setGoogle(); // Treats email auth same as online/google auth
      if (mounted) {
        await context.read<MessProvider>().initialize();
      }

      await _saveAccount(_emailController.text.trim(), _passwordController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        GlassyNotification.show(context, message: _isSignUp
            ? 'Account created! Welcome to Mess Manager.'
            : 'Logged in successfully! Welcome to Mess Manager.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on auth.FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        msg = 'No account found with this email.';
      } else if (e.code == 'wrong-password') { msg = 'Incorrect password.'; }
      else if (e.code == 'invalid-email') { msg = 'Invalid email address.'; }
      else if (e.code == 'weak-password') { msg = 'Password should be at least 6 characters.'; }
      else if (e.code == 'email-already-in-use') { msg = 'An account already exists with this email.'; }
      else if (e.code == 'invalid-credential') { msg = 'Invalid email or password.'; }
      if (mounted) {
        GlassyNotification.show(context, message: msg, isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        GlassyNotification.show(context, message: 'Something went wrong. Check your connection.', isError: true);
      }
    }
  }

  Future<void> _handleForgotPassword(BuildContext ctx) async {
    final emailCtl = TextEditingController(text: _emailController.text.trim());
    final newPwCtl = TextEditingController();
    final confirmPwCtl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (ctx2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isWide = MediaQuery.of(context).size.width > 800;
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              alignment: isWide ? Alignment.center : Alignment.bottomCenter,
              insetPadding: isWide ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24) : const EdgeInsets.only(bottom: 30, left: 16, right: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWide ? 32 : 38)),
              child: isWide
                  ? Container(
                      width: 820,
                      height: 540,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: _buildDesktopResetForm(context, setDialogState, emailCtl, newPwCtl, confirmPwCtl, obscureNew, obscureConfirm),
                      ),
                    )
                  : Container(
                      width: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(38),
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
                        borderRadius: BorderRadius.circular(38),
                        child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(38),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.75),
                                width: 1.5,
                              ),
                            ),
                            child: _buildMobileResetForm(context, setDialogState, emailCtl, newPwCtl, confirmPwCtl, obscureNew, obscureConfirm),
                          ),
                        ),
                      ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopResetForm(BuildContext context, StateSetter setDialogState, TextEditingController emailCtl, TextEditingController newPwCtl, TextEditingController confirmPwCtl, bool obscureNew, bool obscureConfirm) {
    return Stack(
      children: [
        // Left Side: Form Panel
        Positioned(
          left: 0, top: 0, bottom: 0,
          width: 470,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your new password.\nA confirmation email will be sent from Google.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // Email
                      const Text('Email', style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: emailCtl,
                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // New Password
                      const Text('New Password', style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: newPwCtl,
                        obscureText: obscureNew,
                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
                          suffixIcon: GestureDetector(
                            onTap: () => setDialogState(() => obscureNew = !obscureNew),
                            child: Icon(obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password
                      const Text('Confirm Password', style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: confirmPwCtl,
                        obscureText: obscureConfirm,
                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
                          suffixIcon: GestureDetector(
                            onTap: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            child: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final email = emailCtl.text.trim();
                                  final newPw = newPwCtl.text;
                                  final confirmPw = confirmPwCtl.text;
                                  if (email.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
                                    GlassyNotification.show(context, message: 'Please fill all fields.', isError: true);
                                    return;
                                  }
                                  if (newPw != confirmPw) {
                                    GlassyNotification.show(context, message: 'Passwords do not match.', isError: true);
                                    return;
                                  }
                                  if (newPw.length < 6) {
                                    GlassyNotification.show(context, message: 'Password must be at least 6 characters.', isError: true);
                                    return;
                                  }
                                  try {
                                    await FirebaseService().resetPassword(email);
                                    if (context.mounted) {
                                      Navigator.pop(context, false);
                                      _showResetSuccessDialog(email);
                                    }
                                  } on auth.FirebaseAuthException catch (e) {
                                    String msg = 'Failed.';
                                    if (e.code == 'user-not-found') {
                                      msg = 'No account found with this email.';
                                    } else if (e.code == 'invalid-email') { msg = 'Invalid email address.'; }
                                    if (context.mounted) GlassyNotification.show(context, message: msg, isError: true);
                                  } catch (e) {
                                    if (context.mounted) GlassyNotification.show(context, message: 'Something went wrong. Check your connection.', isError: true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF344C44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
        // Right Side: Stacking Papercut waves & artwork
        Positioned(
          right: 0, top: 0, bottom: 0,
          width: 420,
          child: Stack(
            children: [
              Positioned(top: 0, bottom: 0, right: -36, width: 420,
                child: ClipPath(
                  clipper: VerticalWavyClipper(),
                  child: Container(color: const Color(0xFF0F172A).withValues(alpha: 0.08)),
                ),
              ),
              Positioned(top: 0, bottom: 0, right: -24, width: 420,
                child: ClipPath(
                  clipper: VerticalWavyClipper(),
                  child: Container(color: const Color(0xFFF1F5F9)),
                ),
              ),
              Positioned(top: 0, bottom: 0, right: -12, width: 420,
                child: ClipPath(
                  clipper: VerticalWavyClipper(),
                  child: Container(color: const Color(0xFF0F172A).withValues(alpha: 0.12)),
                ),
              ),
              Positioned(top: 0, bottom: 0, right: 0, width: 420,
                child: ClipPath(
                  clipper: VerticalWavyClipper(),
                  child: Image.asset('assets/images/tropical_leaves.png', fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileResetForm(BuildContext context, StateSetter setDialogState, TextEditingController emailCtl, TextEditingController newPwCtl, TextEditingController confirmPwCtl, bool obscureNew, bool obscureConfirm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reset Password',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'A confirmation email will be sent from Google.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 24),

          const Text('Email', style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: emailCtl,
            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),

          const Text('New Password', style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: newPwCtl,
            obscureText: obscureNew,
            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
              suffixIcon: GestureDetector(
                onTap: () => setDialogState(() => obscureNew = !obscureNew),
                child: Icon(obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),

          const Text('Confirm Password', style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: confirmPwCtl,
            obscureText: obscureConfirm,
            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5)),
              suffixIcon: GestureDetector(
                onTap: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                child: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailCtl.text.trim();
                      final newPw = newPwCtl.text;
                      final confirmPw = confirmPwCtl.text;
                      if (email.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
                        GlassyNotification.show(context, message: 'Please fill all fields.', isError: true);
                        return;
                      }
                      if (newPw != confirmPw) {
                        GlassyNotification.show(context, message: 'Passwords do not match.', isError: true);
                        return;
                      }
                      if (newPw.length < 6) {
                        GlassyNotification.show(context, message: 'Password must be at least 6 characters.', isError: true);
                        return;
                      }
                      try {
                        await FirebaseService().resetPassword(email);
                        if (context.mounted) {
                          Navigator.pop(context, false);
                          _showResetSuccessDialog(email);
                        }
                      } on auth.FirebaseAuthException catch (e) {
                        String msg = 'Failed.';
                        if (e.code == 'user-not-found') {
                          msg = 'No account found with this email.';
                         } else if (e.code == 'invalid-email') { msg = 'Invalid email address.'; }
                        if (context.mounted) GlassyNotification.show(context, message: msg, isError: true);
                      } catch (e) {
                        if (context.mounted) GlassyNotification.show(context, message: 'Something went wrong. Check your connection.', isError: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF344C44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Reset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveAccount(String email, String password) async {
    try {
      final existing = await _secureStorage.read(key: 'saved_emails');
      List<Map<String, String>> accounts = [];
      if (existing != null) {
        final list = jsonDecode(existing) as List;
        accounts = list.map((e) => Map<String, String>.from(e as Map)).toList();
        accounts.removeWhere((a) => a['email'] == email);
      }
      accounts.insert(0, {'email': email, 'password': password});
      if (accounts.length > 5) accounts = accounts.sublist(0, 5);
      await _secureStorage.write(key: 'saved_emails', value: jsonEncode(accounts));
      if (mounted) setState(() => _savedAccounts = accounts);
    } catch (_) {}
  }

  Future<void> _loadSavedAccounts() async {
    try {
      final existing = await _secureStorage.read(key: 'saved_emails');
      if (existing != null) {
        final list = jsonDecode(existing) as List;
        if (mounted) {
          setState(() {
          _savedAccounts = list.map((e) {
            // Backward compatibility with old string list
            if (e is String) return {'email': e, 'password': ''};
            return Map<String, String>.from(e as Map);
          }).toList();
        });
        }
      }
    } catch (_) {
    }
  }

  Future<void> _deleteSavedAccount(String email) async {
    setState(() => _savedAccounts.removeWhere((a) => a['email'] == email));
    await _secureStorage.write(key: 'saved_emails', value: jsonEncode(_savedAccounts));
  }

  void _showSavedAccountsSheet() {
    final isWide = MediaQuery.of(context).size.width > 800;
    showGlassDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isWide ? 28 : 24)),
          child: Container(
            width: isWide ? 400 : MediaQuery.of(ctx).size.width * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isWide ? 28 : 24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Saved Emails',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, size: 14, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap an email to fill it in quickly.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                if (_savedAccounts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No saved accounts.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
                  )
                else
..._savedAccounts.map((account) {
                    final email = account['email'] ?? '';
                    final password = account['password'] ?? '';
                    return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _emailController.text = email;
                        if (password.isNotEmpty) {
                          _passwordController.text = password;
                          _handleLogin(); // Trigger auto-login
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF0F766E),
                              child: Text(
                                email.isNotEmpty ? email[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                email,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(ctx);
                                _deleteSavedAccount(email);
                                if (context.mounted) {
                                  GlassyNotification.show(context, message: 'Account removed.', isError: false);
                                }
                              },
                              child: Container(
                                width: 26, height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline, size: 13, color: Color(0xFFEF4444)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, size: 14, color: Color(0xFFCBD5E1)),
                          ],
                        ),
                      ),
                    ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showResetSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.08), blurRadius: 40, offset: const Offset(0, 16)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
                  child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF059669), size: 28),
                ),
                const SizedBox(height: 16),
                const Text('Check Your Inbox', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text(
                  'We sent a password reset email to',
                  style: TextStyle(fontSize: 12, color: const Color(0xFF64748B).withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tipRow(Icons.email_outlined, 'Sender: Firebase / noreply@mess-manager-6dcce.firebaseapp.com'),
                      const SizedBox(height: 6),
                      _tipRow(Icons.subject, 'Subject: "Reset your password"'),
                      const SizedBox(height: 6),
                      _tipRow(Icons.warning_amber_rounded, 'Also check your Spam/Promotions folder'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 42,
                  child: ElevatedButton(
                    onPressed: () async {
                      final uri = Uri.parse('mailto:$email?subject=Reset your password for Mess Manager');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF344C44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Open Email App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity, height: 42,
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await FirebaseService().resetPassword(email);
                        if (context.mounted) {
                          GlassyNotification.show(context, message: 'Reset email resent to $email', isError: false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          GlassyNotification.show(context, message: 'Failed to resend. Try again.', isError: true);
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: const Text('Resend Email', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('I\'ll do it later', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tipRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF475569)))),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await GoogleSignInDesktop.signIn(context: context);
      if (result != null) {
        await AuthModeService.setGoogle();
        if (mounted) {
          await context.read<MessProvider>().initialize();
          if (mounted) {
            setState(() => _isLoading = false);
            GlassyNotification.show(context, message: 'Logged in with Google successfully!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Google sign-in error: $e');
      if (mounted) {
        GlassyNotification.show(context, message: 'Google sign-in failed: $e', isError: true);
      }
    }
  }

  Future<void> _handleOfflineMode() async {
    await AuthModeService.setOffline();
    if (mounted) {
      await context.read<MessProvider>().initialize();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Prevents white edges on mobile notches
      body: Stack(
        children: [
          // Full-screen blurred background image
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Image.asset(
                'assets/images/login_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark gradient overlay to improve glass card contrast against white/bright background spots
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65), // Darker at the top to hide white spots
                    Colors.black.withValues(alpha: 0.2), // Lighter at bottom
                  ],
                ),
              ),
            ),
          ),

          // Centered glass card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: _buildGlassCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 500 ? 420.0 : screenWidth * 0.92;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title & Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isSignUp ? 'Sign Up' : 'Login',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSignUp = !_isSignUp),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _isSignUp ? 'Login' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? 'Create your account to get started'
                    : 'welcome back please login to your account',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Full Name (only for sign up)
              if (_isSignUp) ...[
                _buildGlassTextField(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
              ],

              // Email Field
              _buildGlassTextField(
                controller: _emailController,
                hint: _isSignUp ? 'Email' : 'User Name',
                icon: Icons.person_outline,
                suffixWidget: _savedAccounts.isNotEmpty && !_isSignUp
                    ? GestureDetector(
                        onTap: _showSavedAccountsSheet,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: const Color(0xFF5A5A5A).withValues(alpha: 0.7),
                          size: 22,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Password Field
              _buildGlassTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                isPassword: true,
                onIconTap: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),

              // Remember me + Forget Password row
              if (!_isSignUp)
                Row(
                  children: [
                    // Remember me checkbox (visual only)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B8E7B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _handleForgotPassword(context),
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Login / Sign Up Button (gradient)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Emerald green color
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),



              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.45), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.45), thickness: 1)),
                ],
              ),
              const SizedBox(height: 16),

              // Bottom Actions: Google & Offline Mode
              Row(
                children: [
                  // Google Sign-In (Left)
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: Image.asset(
                          'assets/icons/google.png',
                          width: 18,
                          height: 18,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.35),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Offline Mode (Right)
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleOfflineMode,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.15),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Offline Mode',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? onIconTap,
    Widget? suffixWidget,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? _obscurePassword : false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                isDense: true,
              ),
            ),
          ),
          if (suffixWidget != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: suffixWidget,
            ),
          GestureDetector(
            onTap: onIconTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                icon,
                size: 20,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Wavy Clipper (used in Reset Password Dialog) ====================
class VerticalWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);

    final waveWidth = w * 0.28;
    final segmentHeight = h / 4;

    path.moveTo(0, 0);
    for (int i = 0; i < 4; i++) {
      final startY = segmentHeight * i;
      final endY = segmentHeight * (i + 1);
      final midY = (startY + endY) / 2;
      path.quadraticBezierTo(waveWidth, midY, 0, endY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
