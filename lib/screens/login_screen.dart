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
  List<String> _savedEmails = [];
  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _loadSavedEmails();
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      await _saveEmail(_emailController.text.trim());

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
                                      _showResetSuccessDialog(context, email);
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
                          _showResetSuccessDialog(context, email);
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

  Future<void> _saveEmail(String email) async {
    try {
      final existing = await _secureStorage.read(key: 'saved_emails');
      List<String> emails = [];
      if (existing != null) {
        final list = jsonDecode(existing) as List;
        emails = list.map((e) => e as String).toList();
        emails.removeWhere((e) => e == email);
      }
      emails.insert(0, email);
      if (emails.length > 5) emails = emails.sublist(0, 5);
      await _secureStorage.write(key: 'saved_emails', value: jsonEncode(emails));
      if (mounted) setState(() => _savedEmails = emails);
    } catch (_) {}
  }

  Future<void> _loadSavedEmails() async {
    try {
      final existing = await _secureStorage.read(key: 'saved_emails');
      if (existing != null) {
        final list = jsonDecode(existing) as List;
        if (mounted) {
          setState(() {
          _savedEmails = list.map((e) => e as String).toList();
        });
        }
      }
    } catch (_) {
    }
  }

  Future<void> _deleteSavedEmail(String email) async {
    setState(() => _savedEmails.removeWhere((e) => e == email));
    await _secureStorage.write(key: 'saved_emails', value: jsonEncode(_savedEmails));
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
                if (_savedEmails.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No saved accounts.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
                  )
                else
                  ..._savedEmails.map((email) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _emailController.text = email;
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
                                email[0].toUpperCase(),
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
                                _deleteSavedEmail(email);
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
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fillSavedEmail(String email) {
    _emailController.text = email;
  }

  void _showResetSuccessDialog(BuildContext ctx, String email) {
    showGlassDialog(
      context: ctx,
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
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWide = screenWidth > 800;

    return Scaffold(
      body: isWide
          ? Stack(
              children: [
                // 1. Background image for desktop
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/tropical_leaves.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                // 2. Main Login Card Container
                Center(
                  child: _buildDesktopLayout(context),
                ),
              ],
            )
          : _buildMobileLayout(context),
    );
  }

  // 3D Layered Wavy Papercut Desktop Layout with parallel shifted clippers
  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
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
        child: Stack(
          children: [
            // Left Side: Form Panel (Starts from left 0 to width 470)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 470,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300), // Narrower form matching reference
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isSignUp ? 'Sign Up' : 'Log in',
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildLoginForm(isMobile: false),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Right Side: Stacking Papercut waves & Green leaves artwork (occupies width 420 overlapping the form)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 420,
              child: Stack(
                children: [
                  // Layer 1: Outer Shadow Wave (peeks out furthest left)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: -36,
                    width: 420,
                    child: ClipPath(
                      clipper: VerticalWavyClipper(),
                      child: Container(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Layer 2: Light Grey/White Paper Wave
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: -24,
                    width: 420,
                    child: ClipPath(
                      clipper: VerticalWavyClipper(),
                      child: Container(
                        color: const Color(0xFFF1F5F9),
                      ),
                    ),
                  ),
                  // Layer 3: Inner Shadow Wave (on paper)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: -12,
                    width: 420,
                    child: ClipPath(
                      clipper: VerticalWavyClipper(),
                      child: Container(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Layer 4: Main Wave showing the tropical leaf illustration
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 420,
                    child: ClipPath(
                      clipper: VerticalWavyClipper(),
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/tropical_leaves.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile layout: Features a full-screen blurred leaves background and centered frosted glass card overlay
  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          // 1. Full-screen green leaves background
          Positioned.fill(
            child: Image.asset(
              'assets/images/tropical_leaves.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark translucent overlay to pop the card
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.24),
            ),
          ),
          // 2. Glassmorphic center card containing the login form
          Center(
            child: Container(
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
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 1.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSignUp ? 'Sign Up' : 'Log in',
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLoginForm(isMobile: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Form Fields & Button
  Widget _buildLoginForm({bool isMobile = false}) {
    const textColor = Color(0xFF0F172A); // Deep black-slate for maximum contrast
    const subColor = Color(0xFF475569); // Dark grey-slate for label visibility
    final textFillColor = isMobile ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.85);
    final textBorderColor = Colors.grey.withValues(alpha: 0.24);
    final textFocusedBorderColor = const Color(0xFF0D9488);
    final suffixIconColor = Colors.grey[500];
    final dividerColor = isMobile ? Colors.grey.withValues(alpha: 0.35) : Colors.grey.withValues(alpha: 0.24);
    final linkColor = const Color(0xFF0F766E);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Name Field (only for sign up)
        if (_isSignUp) ...[
          const Text(
            'Full Name',
            style: TextStyle(
              color: subColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: textFillColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 22 : 16),
                borderSide: BorderSide(color: textBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isMobile ? 22 : 16),
                borderSide: BorderSide(color: textFocusedBorderColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 1. Email Field
        const Text(
          'Email',
          style: TextStyle(
            color: subColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          style: const TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: textFillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 22 : 16),
              borderSide: BorderSide(color: textBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 22 : 16),
              borderSide: BorderSide(color: textFocusedBorderColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Password Field
        const Text(
          'Password',
          style: TextStyle(
            color: subColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          style: const TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: textFillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 22 : 16),
              borderSide: BorderSide(color: textBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 22 : 16),
              borderSide: BorderSide(color: textFocusedBorderColor, width: 1.5),
            ),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: suffixIconColor,
                size: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 2b. Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => _handleForgotPassword(context),
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: linkColor, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Login/Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF344C44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 22 : 16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    _isSignUp ? 'Sign Up' : 'Log in',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // 3b. Saved Accounts Quick Login
        if (!_isSignUp && _savedEmails.isNotEmpty) ...[
          Center(
            child: GestureDetector(
              onTap: _showSavedAccountsSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._savedEmails.take(3).map((email) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFF0F766E),
                        child: Text(email[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )),
                    Text(
                      '${_savedEmails.length} saved email${_savedEmails.length > 1 ? 's' : ''}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 4. Toggle Login/Sign Up
        Center(
          child: TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp ? 'Already have an account? Log in' : 'Don\'t have an account? Sign up',
              style: TextStyle(
                color: linkColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        if (!_isSignUp && _googleSupported) ...[
          const SizedBox(height: 4),
          // 5. "or log in with" Divider
          Row(
            children: [
              Expanded(child: Divider(color: dividerColor)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or log in with',
                  style: TextStyle(color: subColor, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Divider(color: dividerColor)),
            ],
          ),
          const SizedBox(height: 16),

          // 6. Social Buttons (Google only)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _handleGoogleSignIn,
                child: _buildSocialButton(
                  isMobile: isMobile,
                  child: Image.asset(
                    'assets/icons/google.png',
                    width: 26,
                    height: 26,
                    errorBuilder: (context, error, stackTrace) => const Text('G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7. Offline Mode Button
          GestureDetector(
            onTap: _isLoading ? null : _handleOfflineMode,
            child: Container(
              width: double.infinity,
              height: isMobile ? 42 : 44,
              decoration: BoxDecoration(
                color: isMobile ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
                border: Border.all(
                  color: isMobile ? Colors.white.withValues(alpha: 0.35) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 18, color: isMobile ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Offline Mode',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isMobile ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (!_isSignUp && !_googleSupported) const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Social Button Widget
  Widget _buildSocialButton({required Widget child, bool isMobile = false}) {
    final socialBg = isMobile ? Colors.white.withValues(alpha: 0.6) : Colors.white;
    final socialBorder = isMobile ? Colors.white.withValues(alpha: 0.35) : Colors.grey.withValues(alpha: 0.24);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: socialBg,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 12),
        border: Border.all(color: socialBorder),
      ),
      child: Center(child: child),
    );
  }
}

// ==================== Mathematically Parallel Wavy Clipper (Desktop) ====================
class VerticalWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    path.lineTo(w, 0);
    path.lineTo(w, h);
    
    // Smooth parallel bezier S-waves relative to the width (prevents squishing on narrow mobile screens)
    path.lineTo(w * 0.14, h);
    path.cubicTo(
      w * 0.14, h * 0.8,
      w * 0.40, h * 0.72,
      w * 0.40, h * 0.62,
    );
    path.cubicTo(
      w * 0.40, h * 0.52,
      w * 0.06, h * 0.48,
      w * 0.06, h * 0.38,
    );
    path.cubicTo(
      w * 0.06, h * 0.28,
      w * 0.28, h * 0.2,
      w * 0.19, 0.0,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ==================== Diagonal 3D Wavy Clipper (Mobile) ====================
class MobileWavyClipper extends CustomClipper<Path> {
  final Offset offset;
  MobileWavyClipper({this.offset = Offset.zero});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    // Diagonal wave starting from top-left to middle-right and down to bottom-left
    final startX = 0.0 + offset.dx;
    final startY = 0.0 + offset.dy;
    
    path.moveTo(startX, startY);
    path.lineTo(w + offset.dx, startY);
    path.lineTo(w + offset.dx, h * 0.32 + offset.dy);
    
    // Smooth responsive S-curves going diagonally across the screen
    path.cubicTo(
      w * 0.82 + offset.dx, h * 0.40 + offset.dy,
      w * 0.68 + offset.dx, h * 0.34 + offset.dy,
      w * 0.52 + offset.dx, h * 0.52 + offset.dy,
    );
    path.cubicTo(
      w * 0.36 + offset.dx, h * 0.70 + offset.dy,
      w * 0.18 + offset.dx, h * 0.64 + offset.dy,
      startX, h * 0.78 + offset.dy,
    );
    
    path.lineTo(startX, startY);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant MobileWavyClipper oldClipper) => oldClipper.offset != offset;
}
