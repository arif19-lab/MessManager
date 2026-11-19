import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final Widget content;
  final Color accentColor;
  final IconData icon;
  final String? iconAssetPath;
  final double progressValue; // 0.0 to 1.0 for the circular progress ring
  final String progressLabel;

  const DashboardCard({
    super.key,
    required this.title,
    required this.content,
    required this.accentColor,
    required this.icon,
    this.iconAssetPath,
    this.progressValue = 0.5,
    this.progressLabel = '',
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final double gapHeight = isDesktop ? 6.0 : 4.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? Matrix4.translationValues(0.0, -6.0, 0.0)
            : Matrix4.translationValues(0.0, 0.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.0),
          boxShadow: [
            // Ambient Web-style Glassmorphism Elevation
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: _isHovered ? 0.45 : 0.25)
                  : const Color(0xFF0F172A).withValues(alpha: _isHovered ? 0.12 : 0.07),
              blurRadius: _isHovered ? 24 : 16,
              offset: Offset(0, _isHovered ? 8 : 5),
            ),
          ],
        ),
        // ── Single Unified Seamless Glass HUD Architecture ──
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: isDark
                    ? const Color(0x18FFFFFF)
                    : Colors.white.withValues(alpha: 0.90),
                border: Border.all(
                  color: isDark
                      ? (_isHovered
                          ? widget.accentColor.withValues(alpha: 0.85)
                          : const Color(0x35FFFFFF))
                      : (_isHovered
                          ? widget.accentColor
                          : const Color(0x2E000000)),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon on left, Progress Ring on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon wrapper with glossy glass treatment
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: isDark ? 0.85 : 0.90),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: isDark ? 0.3 : 0.6),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.40),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: widget.iconAssetPath != null
                            ? Image.asset(
                                widget.iconAssetPath!,
                                width: 18,
                                height: 18,
                                color: Colors.white,
                              )
                            : Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                      // Circular progress ring
                      if (widget.progressValue >= 0.0)
                        NeumorphicCircularProgress(
                          progress: widget.progressValue,
                          progressLabel: widget.progressLabel,
                          accentColor: widget.accentColor,
                          useGradient: false,
                          size: 32,
                        ),
                    ],
                  ),
                  const Spacer(),
                  // Title text
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        fontWeight: FontWeight.w800,
                        fontSize: 9.5,
                        letterSpacing: 1.1,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: gapHeight),
                  // Value content
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: widget.content,
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
}

// ── Sunken circular progress background ──
class NeumorphicCircularProgress extends StatelessWidget {
  final double progress;
  final String progressLabel;
  final Color accentColor;
  final bool useGradient;
  final double size;
  final double strokeWidth;

  const NeumorphicCircularProgress({
    super.key,
    required this.progress,
    required this.progressLabel,
    required this.accentColor,
    required this.useGradient,
    this.size = 32,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner circular track (translucent glass look)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: useGradient 
                  ? Colors.white.withValues(alpha: 0.15) 
                  : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
          ),
          // Custom Painted Sweep Progress
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              color: accentColor,
              useGradient: useGradient,
            ),
          ),
          if (progressLabel.isNotEmpty)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  progressLabel,
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    color: useGradient ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool useGradient;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.useGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (useGradient) {
      paint.color = Colors.white;
    } else {
      paint.shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.7),
          color,
          color.withValues(alpha: 0.7),
        ],
      ).createShader(rect);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2); // Start from top
    
    final localRect = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawArc(
      localRect,
      0,
      progress * 2 * math.pi,
      false,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
}

class SingleValueBox extends StatelessWidget {
  final String value;
  final String subLabel;

  const SingleValueBox({
    super.key,
    required this.value,
    this.subLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final String cleanValue;
    final String suffix;
    if (value.contains(' - ৳')) {
      final parts = value.split(' - ৳');
      cleanValue = parts[0];
      suffix = ' - ৳';
    } else {
      cleanValue = value;
      suffix = '';
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: cleanValue,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (suffix.isNotEmpty)
            TextSpan(
              text: suffix,
              style: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class ActiveMembersBox extends StatelessWidget {
  final int totalActive;
  final int todayActive;

  const ActiveMembersBox({
    super.key,
    required this.totalActive,
    required this.todayActive,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Tooltip(
      message: '$todayActive members have at least 1 meal today\n$totalActive total active members in this cycle',
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$todayActive',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: ' / ',
              style: TextStyle(
                color: isDark ? Colors.grey[600] : const Color(0xFFCBD5E1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: '$totalActive',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: '  EATING TODAY',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

