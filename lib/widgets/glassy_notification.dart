import 'package:flutter/material.dart';

/// Shows a beautiful floating notification SnackBar.
class GlassyNotification {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError 
                ? const Color(0xFFEF4444).withValues(alpha: 0.9) 
                : const Color(0xFF10B981).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isError 
                  ? const Color(0xFFFCA5A5).withValues(alpha: 0.3) 
                  : const Color(0xFF6EE7B7).withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
