import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class GlassyThemeSwitch extends StatefulWidget {
  final ThemeProvider themeProvider;
  final VoidCallback onToggle;

  const GlassyThemeSwitch({
    super.key,
    required this.themeProvider,
    required this.onToggle,
  });

  @override
  State<GlassyThemeSwitch> createState() => _GlassyThemeSwitchState();
}

class _GlassyThemeSwitchState extends State<GlassyThemeSwitch> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.themeProvider.isDarkMode;
  }

  @override
  void didUpdateWidget(covariant GlassyThemeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeProvider.isDarkMode != widget.themeProvider.isDarkMode) {
      isDark = widget.themeProvider.isDarkMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exact sizing to match reference proportion
    const double trackWidth = 150.0;
    const double trackHeight = 52.0;
    const double thumbOuterSize = 80.0;
    const double thumbInnerSize = 40.0;
    
    // Position math
    const double padding = -((thumbOuterSize - trackHeight) / 2);
    final double leftPosition = isDark ? (trackWidth - thumbOuterSize - padding) : padding;

    return GestureDetector(
      onTapUp: (details) {
        final bool tappedRightSide = details.localPosition.dx > (trackWidth / 2);
        
        // If tapped the side that is already active, ignore it!
        if (tappedRightSide && isDark) return;
        if (!tappedRightSide && !isDark) return;
        
        widget.onToggle();
        setState(() => isDark = !isDark);
      },
      child: SizedBox(
        width: trackWidth,
        height: thumbOuterSize, // Accommodate the larger thumb
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // --- TRACK ---
            Container(
              width: trackWidth,
              height: trackHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackHeight / 2),
                // Very glassy track base
                color: isDark 
                    ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.4),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [Colors.black.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0.05)]
                      : [Colors.black.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Light Text
                  AnimatedOpacity(
                    opacity: isDark ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 24.0),
                        child: Text(
                          'Light',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Inter', // Assuming standard modern sans
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // Crisp white like in the image
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Dark Text
                  AnimatedOpacity(
                    opacity: isDark ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 24.0),
                        child: Text(
                          'Dark',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- THUMB ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              left: leftPosition,
              child: _buildThumb(thumbOuterSize, thumbInnerSize, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(double outerSize, double innerSize, bool isDark) {
    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Outer Glass Dome
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Base tint
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.15),
                    // Realistic glass reflection gradient
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // The Inner Solid Circle with Icon
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [const Color(0xFF334155), const Color(0xFF0F172A)]
                    : [Colors.white, const Color(0xFFE2E8F0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
                BoxShadow(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.9),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: isDark ? Colors.white : const Color(0xFF64748B),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
