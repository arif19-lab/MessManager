import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThemeTransitionController {
  static _ThemeTransitionWrapperState? _instance;

  static void run(VoidCallback applyTheme) {
    if (_instance == null) {
      applyTheme();
      return;
    }
    _instance!._startReveal(applyTheme);
  }
}

class ThemeTransitionWrapper extends StatefulWidget {
  final Widget child;
  const ThemeTransitionWrapper({required this.child, super.key});

  @override
  State<ThemeTransitionWrapper> createState() => _ThemeTransitionWrapperState();
}

class _ThemeTransitionWrapperState extends State<ThemeTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _running = false;
  bool _goingDark = false;

  @override
  void initState() {
    super.initState();
    ThemeTransitionController._instance = this;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInExpo,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _running = false);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    ThemeTransitionController._instance = null;
    _controller.dispose();
    super.dispose();
  }

  void _startReveal(VoidCallback applyTheme) {
    if (!mounted) {
      applyTheme();
      return;
    }

    // Always force the animation on every valid theme change
    _goingDark = Theme.of(context).brightness == Brightness.light;
    _running = true;

    applyTheme();

    setState(() {});
    
    // Stop any currently running animation and forcefully restart
    _controller.stop();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_running)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (ctx, _) {
                  final size = MediaQuery.of(ctx).size;
                  final maxRadius = math.sqrt(
                    size.width * size.width + size.height * size.height,
                  );

                  return CustomPaint(
                    painter: _WipePainter(
                      progress: _animation.value,
                      maxRadius: maxRadius,
                      goingDark: _goingDark,
                    ),
                    size: size,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _WipePainter extends CustomPainter {
  final double progress;
  final double maxRadius;
  final bool goingDark;

  const _WipePainter({
    required this.progress,
    required this.maxRadius,
    required this.goingDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = progress * maxRadius * 1.3;

    final center = goingDark
        ? Offset(0, size.height) // bottom-left
        : Offset(size.width, 0); // top-right

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    path.fillType = PathFillType.evenOdd;

    canvas.clipPath(path);

    // Overlay is OPPOSITE color of new theme
    final overlayColor = goingDark
        ? Colors.white.withValues(alpha: 0.97) 
        : Colors.black.withValues(alpha: 0.97);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = overlayColor,
    );
  }

  @override
  bool shouldRepaint(_WipePainter old) => old.progress != progress;
}
