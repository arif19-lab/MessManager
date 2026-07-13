import 'dart:math' as math;
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

class _DashboardCardState extends State<DashboardCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
            ? Matrix4.translationValues(0.0, -8.0, 0.0) // Lift up even more on hover
            : Matrix4.translationValues(0.0, 0.0, 0.0),
        decoration: BoxDecoration(
          color: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),

          ),
          borderRadius: BorderRadius.circular(20.0), // Rounded matching mockup
          border: Border.all(
            color: const Color(0xFF0080FF),
            width: 1.5,
          ),
          boxShadow: [
            // Solid, flat offset shadow with 0 blur matching modern Flat 2.0 / Neo-Brutalist style
            BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0xFF0F172A).withValues(alpha: 0.12),
                offset: Offset(0, _isHovered ? 6 : 4),
                blurRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              // Large artistic background watermark icon to fill space elegantly
              // Small artistic rounded container icon at bottom right
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    width: isDesktop ? 40.0 : 35.0,
                    height: isDesktop ? 40.0 : 35.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0080FF),
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: isDesktop ? 26.0 : 22.0,
                        height: isDesktop ? 26.0 : 22.0,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: WavePainter(
                                animationValue: _pulseController.value,
                                color: widget.accentColor,
                                isDark: isDark,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Main card content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon on left, Progress Ring on right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icon wrapper (Rounded outline matching modern Flat 2.0 style)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: isDark ? 0.85 : 0.90),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: widget.accentColor,
                              width: 1.2,
                            ),
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
                        // Neumorphic circular progress ring
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
                    // Title text (small, bold, uppercase with letter-spacing for premium feel)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          fontWeight: FontWeight.w900,
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
            ],
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
          // Inner circular track (sunken neumorphic look)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: useGradient 
                  ? Colors.white.withValues(alpha: 0.15) 
                  : (isDark ? const Color(0xFF0A0F1D) : const Color(0xFFE2E8F0)),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF0F172A),
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

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isDark;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final double width = size.width;

    // Paint a single flowing wave (solid/neon)
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fgPath = Path();
    fgPath.moveTo(0, midY);
    for (double x = 0; x <= width; x++) {
      final double relativeX = x / width;
      final double y = midY + 
          math.sin((relativeX * 2.0 * math.pi) + (animationValue * 2 * math.pi)) * 4.5;
      if (x == 0) {
        fgPath.moveTo(x, y);
      } else {
        fgPath.lineTo(x, y);
      }
    }
    canvas.drawPath(fgPath, fgPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}

class LiquidWavePainter extends CustomPainter {
  final double animationValue;
  final double progressValue;
  final Color color;
  final bool isDark;

  LiquidWavePainter({
    required this.animationValue,
    required this.progressValue,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pct = progressValue < 0.0 ? 0.5 : progressValue.clamp(0.15, 1.0);
    final double width = size.width;
    final double height = size.height;
    final double targetY = height * (1.0 - pct);

    // 1. Draw background liquid wave (lighter opacity)
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final bgPath = Path();
    bgPath.moveTo(0, height);
    bgPath.lineTo(0, targetY);
    for (double x = 0; x <= width; x++) {
      final double relativeX = x / width;
      final double y = targetY + 
          math.sin((relativeX * 2.5 * math.pi) - (animationValue * 2 * math.pi)) * 2.2;
      bgPath.lineTo(x, y);
    }
    bgPath.lineTo(width, height);
    bgPath.close();
    canvas.drawPath(bgPath, bgPaint);

    // 2. Draw foreground liquid wave (darker/solid opacity)
    final fgPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final fgPath = Path();
    fgPath.moveTo(0, height);
    fgPath.lineTo(0, targetY);
    for (double x = 0; x <= width; x++) {
      final double relativeX = x / width;
      final double y = targetY + 
          math.sin((relativeX * 2.0 * math.pi) + (animationValue * 2 * math.pi)) * 2.8;
      fgPath.lineTo(x, y);
    }
    fgPath.lineTo(width, height);
    fgPath.close();
    canvas.drawPath(fgPath, fgPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.progressValue != progressValue ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}

