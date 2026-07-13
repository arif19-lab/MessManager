import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class GoogleSignInDesktop {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static GoogleSignIn get googleSignIn => _googleSignIn;

  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // On Windows/Linux, local loopback doesn't maintain a persistent google_sign_in session.
      // Disconnect is handled by Firebase Auth sign out.
    }
  }

  static Future<UserCredential?> signIn({BuildContext? context}) async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return await FirebaseAuth.instance.signInWithPopup(provider);
    }

    try {
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (_) {
      return null;
    }

    // Windows/Linux Flow: System Browser Loopback Server
    return await _systemBrowserSignIn(context);
  }

  static Future<UserCredential?> _systemBrowserSignIn(BuildContext? context) async {
    final clientId = '716451290126-vetvab60g1qc38koce9tk1te32clk6m9.apps.googleusercontent.com';
    final port = 8080;
    final redirectUri = 'http://localhost:$port';
    final nonce = generateNonce();

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'token id_token',
      'scope': 'openid email profile',
      'nonce': nonce,
      'prompt': 'select_account',
    });

    HttpServer? server;
    Completer<UserCredential?> completer = Completer();

    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } catch (e) {
      debugPrint('Failed to start local server on port $port: $e');
      return null;
    }

    server.listen((HttpRequest request) async {
      try {
        if (request.uri.path == '/') {
          // Serve HTML page that extracts the URL fragment (hash) and sends it back to the server
          final html = '''
            <!DOCTYPE html>
            <html>
            <head>
              <title>Authenticating...</title>
              <style>
                body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #0A0A0A; color: white; margin: 0; }
                .container { text-align: center; padding: 40px; background: #161B22; border-radius: 16px; border: 1px solid #30363D; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
                h2 { margin-bottom: 10px; color: #0D9488; }
                p { color: #8B949E; }
              </style>
            </head>
            <body>
              <div class="container" id="message">
                <h2>Completing Sign In...</h2>
                <p>Please wait while we securely log you in.</p>
              </div>
              <script>
                const hash = window.location.hash.substring(1);
                if (hash) {
                  fetch('/token?' + hash).then(() => {
                     document.getElementById('message').innerHTML = '<h2>Login Successful!</h2><p>You can close this tab and return to the app.</p>';
                     setTimeout(() => window.close(), 2000);
                  }).catch(err => {
                     document.getElementById('message').innerHTML = '<h2 style="color:red">Error</h2><p>Failed to send token to app.</p>';
                  });
                } else {
                  document.getElementById('message').innerHTML = '<h2 style="color:red">Authentication Failed</h2><p>No token received.</p>';
                }
              </script>
            </body>
            </html>
          ''';
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..write(html);
          await request.response.close();
        } else if (request.uri.path == '/token') {
          // Parse the extracted tokens sent from JavaScript
          final params = request.uri.queryParameters;
          final accessToken = params['access_token'];
          final idToken = params['id_token'];
          
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.text
            ..write('OK');
          await request.response.close();

          if (accessToken != null || idToken != null) {
            final cred = await _completeWithCredential(accessToken, idToken);
            if (!completer.isCompleted) completer.complete(cred);
          } else {
            if (!completer.isCompleted) completer.complete(null);
          }
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not found');
          await request.response.close();
        }
      } catch (e) {
        debugPrint('Loopback server error: $e');
        if (!completer.isCompleted) completer.complete(null);
      }
    });

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch browser: $authUrl');
      server.close();
      return null;
    }

    // Show a dialog in the app so the user can cancel if they closed the browser
    BuildContext? dialogContext;
    if (context != null && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Authenticating...', style: TextStyle(color: Colors.white, fontSize: 18)),
            content: const Text(
              'Please complete the sign-in process in your browser window.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (!completer.isCompleted) completer.complete(null);
                },
                child: const Text('Cancel', style: TextStyle(color: Color(0xFFEF4444))),
              ),
            ],
          );
        },
      );
    }

    // Wait for the user to complete sign-in (or timeout after 5 minutes)
    final result = await completer.future.timeout(const Duration(minutes: 5), onTimeout: () {
      debugPrint('Sign-in timed out.');
      return null;
    });

    if (dialogContext != null && dialogContext!.mounted) {
      Navigator.of(dialogContext!).pop();
    }

    await server.close(force: true);
    return result;
  }

  static Future<UserCredential?> _completeWithCredential(
    String? accessToken, String? idToken,
  ) async {
    if (idToken == null && accessToken == null) return null;
    try {
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Firebase sign-in error: $e');
      return null;
    }
  }

  static String generateNonce() {
    final random = List<int>.generate(32, (_) => DateTime.now().microsecondsSinceEpoch & 0xFF);
    final bytes = sha256.convert(random).bytes;
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
