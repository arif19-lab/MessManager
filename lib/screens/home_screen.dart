import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/mess_provider.dart';
import '../providers/theme_provider.dart';
import '../models/mess_data.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/profile_dialog.dart';
import '../widgets/theme_transition_wrapper.dart';
import '../widgets/glassy_notification.dart';
import '../l10n/bangla_localizations.dart';
import '../providers/language_provider.dart';
import 'meals_screen.dart';
import 'people_screen.dart';
import 'expenses_screen.dart';
import 'payments_screen.dart';
import 'fried_fine_screen.dart';
import 'customize_home_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'summary_screen.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../widgets/modern_theme_icon.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  int _dashboardKeyCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSettingsPanelOpen = false;
  late final AnimationController _drawerController;

  // Desktop navbar sliding indicator measurement
  final GlobalKey _navTabsRowKey = GlobalKey();
  final List<GlobalKey> _navTabKeys = List.generate(6, (_) => GlobalKey());
  double? _navIndicatorLeft;
  double? _navIndicatorWidth;

  // Snake-molt animation for the sliding indicator (shine sweep + squash-stretch)
  late final AnimationController _navMoltController;

  void _updateNavIndicator() {
    final rowBox = _navTabsRowKey.currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null || !rowBox.hasSize) return;
    if (_currentIndex < 0 || _currentIndex >= _navTabKeys.length) return;
    final tabBox = _navTabKeys[_currentIndex].currentContext?.findRenderObject() as RenderBox?;
    if (tabBox == null || !tabBox.hasSize) return;
    final double left = tabBox.localToGlobal(Offset.zero, ancestor: rowBox).dx;
    final double width = tabBox.size.width;
    if (_navIndicatorLeft != left || _navIndicatorWidth != width) {
      setState(() {
        _navIndicatorLeft = left;
        _navIndicatorWidth = width;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _navMoltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _applySystemUIFromPrefs();
  }

  Future<void> _applySystemUIFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final fullscreen = prefs.getBool('fullscreen_mode') ?? true;
    SystemChrome.setEnabledSystemUIMode(
      fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  void dispose() {
    // Restore edge-to-edge when leaving HomeScreen
    _drawerController.dispose();
    _navMoltController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTabChanged(int index) {
    // Trigger the snake-molt effect only when moving between the 6 main tabs
    final bool moltable = index != _currentIndex &&
        index >= 0 && index < 6 &&
        _currentIndex >= 0 && _currentIndex < 6;
    setState(() {
      _currentIndex = index;
    });
    if (moltable) {
      _navMoltController.forward(from: 0.0);
    }
  }

  List<Widget> get _pages => [
    HomeDashboardView(key: ValueKey(_dashboardKeyCount)),
    const MealsScreen(),
    const PeopleScreen(),
    const ExpensesScreen(),
    const PaymentsScreen(),
    const FriedFineScreen(),
    const SummaryScreen(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    // Apply system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    if (isDesktop) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: themeProvider.resolveColor(
          light: const Color(0xFFE2E8F0),
          dark: const Color(0xFF050505),
        ),
        body: Stack(
          children: [
            Container(
              color: themeProvider.resolveColor(
                light: const Color(0xFFE2E8F0),
                dark: const Color(0xFF050505),
              ),
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: CustomPaint(
                    painter: CurvedPanelPainter(
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      gradient: null,
                      borderColor: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFF0F172A).withValues(alpha: 0.15),
                      shadowColor: isDark ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF0F172A).withValues(alpha: 0.08),
                      shadowOffset: 4.0,
                    ),
                    child: Stack(
                      children: [
                        // Main content clipped below the folder tab cutout
                        Positioned.fill(
                          child: ClipPath(
                            clipper: TabCutoutClipper(),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
                                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                                );
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(scale: scaleAnimation, child: child),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(_currentIndex),
                                child: _pages[_currentIndex],
                              ),
                            ),
                          ),
                        ),

                        // Folder Tab area — top-left (title + greeting)
                        const Positioned(
                          top: 0,
                          left: 0,
                          width: 280,
                          child: AnimatedGreetingsHeader(),
                        ),

                        // Navbar Pills — top-right
                        Positioned(
                          top: 16,
                          right: 16,
                          child: _buildTopPillTabs(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }


    // Mobile Layout (Ultra-Smooth 120FPS Interactive Slide Shift)
    final double drawerWidth = (screenWidth * 0.78).clamp(260.0, 320.0).toDouble();

    // Cache main Scaffold so it is rebuilt 0 times during drawer animation
    final Widget mainScaffold = Container(
      color: themeProvider.resolveColor(
        light: Theme.of(context).scaffoldBackgroundColor,
        dark: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.0 + MediaQuery.of(context).padding.top),
          child: Container(
            color: themeProvider.resolveColor(
              light: Colors.white,
              dark: const Color(0xFF0A0A0A),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      size: 28,
                    ),
                    onPressed: () => _drawerController.animateTo(1.0, curve: Curves.easeOutCubic),
                  ),
                  Consumer<MessProvider>(
                    builder: (context, provider, _) {
                      return GestureDetector(
                        onTap: () => ProfileDialog.show(context),
                        child: ProfileAvatar(
                          radius: 20,
                          customAvatarPath: provider.customAvatarPath,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ), // Closes AnimatedSwitcher
        bottomNavigationBar: _buildAnimatedNavBar(),
      ), // Closes Scaffold
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_drawerController.value > 0.05) {
          _drawerController.animateTo(0.0, curve: Curves.easeOutCubic);
        } else {
          SystemNavigator.pop();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          final delta = details.primaryDelta ?? 0.0;
          _drawerController.value += delta / drawerWidth;
        },
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0.0;
          // Ultra-snappy: any slight flick (>80 or <-80) immediately snaps open or closed!
          if (velocity > 80) {
            _drawerController.animateTo(1.0, curve: Curves.easeOutCubic);
          } else if (velocity < -80) {
            _drawerController.animateTo(0.0, curve: Curves.easeOutCubic);
          } else {
            // Slight touch drag > 14% opens immediately, otherwise closes
            if (_drawerController.value > 0.14) {
              _drawerController.animateTo(1.0, curve: Curves.easeOutCubic);
            } else {
              _drawerController.animateTo(0.0, curve: Curves.easeOutCubic);
            }
          }
        },
        child: AnimatedBuilder(
          animation: _drawerController,
          child: mainScaffold,
          builder: (_, childWidget) {
            final double progress = _drawerController.value;
            final bool isOpen = progress > 0.001;

            return Stack(
              children: [
                // 1. Main Screen - Kept static in place so drawer BackdropFilter blurs it directly!
                childWidget!,

                // 2. Dim Scrim + Live Frosted Blur Overlay strictly outside the drawer panel
                if (isOpen)
                  Positioned(
                    left: drawerWidth * progress,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _drawerController.animateTo(0.0, curve: Curves.easeOutCubic),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 14.0 * progress,
                            sigmaY: 14.0 * progress,
                          ),
                          child: Container(
                            color: Colors.black.withValues(
                              alpha: (isDark ? 0.45 : 0.22) * progress,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 3. Sliding Frosted Glass Drawer Panel (Overlays directly on top of screen with live direct blur)
                if (isOpen)
                  Positioned(
                    left: -drawerWidth * (1.0 - progress),
                    top: 0,
                    bottom: 0,
                    width: drawerWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        final delta = details.primaryDelta ?? 0.0;
                        _drawerController.value += delta / drawerWidth;
                      },
                      onHorizontalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0.0;
                        if (velocity < -80 || _drawerController.value < 0.86) {
                          _drawerController.animateTo(0.0, curve: Curves.easeOutCubic);
                        } else {
                          _drawerController.animateTo(1.0, curve: Curves.easeOutCubic);
                        }
                      },
                      child: DrawerWidget(
                        activeIndex: _currentIndex,
                        onClose: () => _drawerController.animateTo(0.0, curve: Curves.easeOutCubic),
                        onItemTapped: (index) async {
                          _drawerController.animateTo(0.0, curve: Curves.easeOutCubic);
                          if (index == 9) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomizeHomeScreen()),
                            );
                            if (result == true && context.mounted) {
                              await _applySystemUIFromPrefs();
                              if (!context.mounted) return;
                              GlassyNotification.show(context, message: 'Home dashboard customized successfully!');
                              setState(() {
                                _dashboardKeyCount++;
                              });
                            }
                          } else {
                            if (index < _pages.length) {
                              _onTabChanged(index);
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Maps _currentIndex to nav position (0: Home, 1: Meals, 2: People, 3: Settings)
  int get _navIndex {
    if (_currentIndex == 1) return 1;
    if (_currentIndex == 2) return 2;
    if (_currentIndex == 8) return 3; // Settings
    return 0; // Dashboard, Expenses, Payments, FriedFine, Summary, Notifications all fall under Home
  }

  // Maps nav position back to page index
  int _pageIndex(int navPos) {
    if (navPos == 0) return 0;
    if (navPos == 1) return 1;
    if (navPos == 2) return 2;
    return 8; // Mobile Settings
  }

  // Labels updated dynamically in _buildAnimatedNavBar via BanglaLocalizations
  static const List<_NavItemData> _navItems = [
    _NavItemData('Home',     Icons.grid_view_rounded,       'assets/icons/dashboard.png'),
    _NavItemData('Meals',    Icons.restaurant_menu_rounded, 'assets/icons/meals.png'),
    _NavItemData('People',   Icons.people_alt_rounded,      'assets/icons/member.png'),
    _NavItemData('Settings', Icons.settings_rounded,        null),
  ];

  Widget _buildAnimatedNavBar() {
    final bn = BanglaLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GlassTabBar.bottom(
      quality: GlassQuality.standard,
      selectedIndex: (_navIndex >= 0 && _navIndex < 3) ? _navIndex : 0,
      showIndicator: _navIndex < 3,
      onTabSelected: (index) {
        _onTabChanged(_pageIndex(index));
      },
      indicatorPinchStrength: 1.15,
      glowDuration: const Duration(milliseconds: 500),
      magnification: 1.25,
      innerBlur: 2.0,
      pressScale: 1.06,
      indicatorExpansion: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      settings: (isDark ? LiquidGlassSettings.ios27Dark : LiquidGlassSettings.ios27Light).copyWith(
        glassColor: isDark ? const Color(0x381E222A) : const Color(0xD0FFFFFF),
        thickness: 34,
        blur: 26,
        frost: 18,
        frostOpacity: isDark ? 0.90 : 0.82,
        refractiveIndex: 1.26,
        chromaticAberration: 0.05,
        rimLight: isDark ? 1.50 : 1.25,
        rimShade: isDark ? 0.95 : 0.50,
        rimShadeEnds: 0.5,
        edgeAbsorption: 0.035,
        shadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.16),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: isDark ? const Color(0x30FFFFFF) : const Color(0x70FFFFFF),
            blurRadius: 1.5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      indicatorSettings: LiquidGlassSettings.ios27Indicator.copyWith(
        thickness: 36,
        refractiveIndex: 1.26,
        chromaticAberration: 0.05,
        rimLight: 1.5,
        rimShade: 1.1,
      ),
      selectedIconColor: const Color(0xFFFF8C42),
      unselectedIconColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      selectedLabelColor: const Color(0xFFFF8C42),
      unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      tabs: [
        GlassTab(
          icon: _buildNavIcon(0, active: false),
          activeIcon: _buildNavIcon(0, active: true),
          label: bn.navHome,
        ),
        GlassTab(
          icon: _buildNavIcon(1, active: false),
          activeIcon: _buildNavIcon(1, active: true),
          label: bn.navMeals,
        ),
        GlassTab(
          icon: _buildNavIcon(2, active: false),
          activeIcon: _buildNavIcon(2, active: true),
          label: bn.navPeople,
        ),
      ],
      extraButton: GlassTabBarExtraButton(
        icon: RepaintBoundary(
          child: ModernThemeIcon(
            isDark: isDark,
            size: 26,
          ),
        ),
        label: isDark
            ? (bn.isBangla ? 'লাইট' : 'Light')
            : (bn.isBangla ? 'ডার্ক' : 'Dark'),
        placement: GlassExtraButtonPlacement.right,
        onTap: () {
          _triggerThemeTransition(context, themeProvider, !isDark);
        },
      ),
    );
  }

  Widget _buildNavIcon(int navPos, {required bool active}) {
    const double sz = 24.0;
    final Color color = active ? const Color(0xFFFF8C42) : const Color(0xFF8E8EA0);
    final item = _navItems[navPos];
    if (item.assetPath != null) {
      return Image.asset(item.assetPath!, width: sz, height: sz, color: color);
    }
    return Icon(item.icon, size: sz, color: color);
  }

  Widget _buildTopPillTabs(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallDesktop = screenWidth < 1200;

    const double tabSpacing = 6.0;

    // Measure the active tab after each layout so the indicator matches its
    // real (natural) size and position, regardless of label length.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateNavIndicator());

    const int tabCount = 6;
    final bool indicatorVisible = _currentIndex >= 0 && _currentIndex < tabCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Tab buttons with a green pill that glides between them ──
        Stack(
          children: [
            // The sliding green indicator (sits behind the tabs)
            if (_navIndicatorLeft != null && _navIndicatorWidth != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                left: _navIndicatorLeft!,
                top: 0,
                bottom: 0,
                width: _navIndicatorWidth!,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: indicatorVisible ? 1.0 : 0.0,
                  child: _buildMoltPill(),
                ),
              ),
            // The tab buttons on top of the indicator
            Row(
              key: _navTabsRowKey,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFixedTab(0, Icons.grid_view_rounded, BanglaLocalizations.of(context).tabDashboard, showLabel: !isSmallDesktop, tabKey: _navTabKeys[0]),
                const SizedBox(width: tabSpacing),
                _buildFixedTab(1, Icons.restaurant_menu_rounded, BanglaLocalizations.of(context).tabMeals, showLabel: !isSmallDesktop, tabKey: _navTabKeys[1]),
                const SizedBox(width: tabSpacing),
                _buildFixedTab(2, Icons.people_alt_rounded, BanglaLocalizations.of(context).tabPeople, showLabel: !isSmallDesktop, tabKey: _navTabKeys[2]),
                const SizedBox(width: tabSpacing),
                _buildFixedTab(3, Icons.shopping_bag_rounded, BanglaLocalizations.of(context).tabExpenses, showLabel: !isSmallDesktop, tabKey: _navTabKeys[3]),
                const SizedBox(width: tabSpacing),
                _buildFixedTab(4, Icons.credit_card_rounded, BanglaLocalizations.of(context).tabPayments, showLabel: !isSmallDesktop, tabKey: _navTabKeys[4]),
                const SizedBox(width: tabSpacing),
                _buildFixedTab(5, Icons.gavel_rounded, BanglaLocalizations.of(context).tabFeastFines, showLabel: !isSmallDesktop, tabKey: _navTabKeys[5]),
              ],
            ),
          ],
        ),
        const SizedBox(width: 10),
        // Settings Dropdown
        _buildSettingsDropdown(),
      ],
    );
  }


  void _triggerThemeTransition(BuildContext context, ThemeProvider provider, bool targetDark) {
    ThemeTransitionController.run(() => provider.setDarkMode(targetDark));
  }

  void _showSettingsPanel(BuildContext context) {
    setState(() => _isSettingsPanelOpen = true);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim, secondAnim) {
        return const SizedBox.shrink(); // We build the UI in transitionBuilder
      },
      transitionBuilder: (ctx, anim, secondAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutQuart);
        return Stack(
          children: [
            AnimatedBuilder(
              animation: anim,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
                  },
                  child: Container(color: Colors.transparent),
                );
              },
            ),
            Positioned(
              top: 102,
              right: 16,
              child: FadeTransition(
                opacity: curved,
                child: AnimatedBuilder(
                  animation: curved,
                  builder: (context, child) {
                    bool isDark = Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF94A3B8).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: ClipPath(
                        clipper: _SettingsShutterClipper(28.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: curved.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildSettingsPanelContent(ctx),
                ),
              ),
            ),
          ],
        );
      },
    ).then((value) {
      setState(() => _isSettingsPanelOpen = false);
      if (value == null) return;
      _handleSettingsSelection(value as int);
    });
  }

  Future<void> _handleSettingsSelection(int value) async {
    if (value == 8) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomizeHomeScreen()),
      );
      if (result == true && mounted) {
        await _applySystemUIFromPrefs();
        if (!mounted) return;
        GlassyNotification.show(context, message: 'Home dashboard customized successfully!');
        setState(() => _dashboardKeyCount++);
      }
    } else if (value == 7 || value == 6) {
      _onTabChanged(value);
    }
  }

  Widget _buildSettingsPanelContent(BuildContext ctx) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isDark = themeProvider.isDarkMode;
        return Material(
          type: MaterialType.transparency,
          child: Container(
            width: 250,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Neumorphic Appearance Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.05),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                          BanglaLocalizations.of(context).appearance,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        ),
                        const SizedBox(height: 12),
                        // Row 1: Dual Capsule Switches
                        Row(
                          children: [
                            Expanded(
                              child: _NeumorphicSwitch(
                                isActive: !isDark,
                                isDark: isDark,
                                onTap: () => _triggerThemeTransition(context, themeProvider, false),
                                icon: Icons.wb_sunny_rounded,
                                iconColor: Colors.amber,
                                glowColor: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _NeumorphicSwitch(
                                isActive: isDark,
                                isDark: isDark,
                                onTap: () => _triggerThemeTransition(context, themeProvider, true),
                                icon: Icons.nightlight_round,
                                iconColor: const Color(0xFFFFD166),
                                glowColor: const Color(0xFFFFD166),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Row 2: Light / Dark text buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _triggerThemeTransition(context, themeProvider, false),
                                child: Container(
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2D3748) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF0F172A).withValues(alpha: 0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    BanglaLocalizations.of(context).light,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _triggerThemeTransition(context, themeProvider, true),
                                child: Container(
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2D3748) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFF0F172A).withValues(alpha: 0.1),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    BanglaLocalizations.of(context).dark,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
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
                  // ── Language Section ──
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.05),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            BanglaLocalizations.of(context).language,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _LanguageTogglePill(
                                label: 'English',
                                isSelected: !context.watch<LanguageProvider>().isBangla,
                                isDark: isDark,
                                onTap: () {
                                  context.read<LanguageProvider>().setLocale(const Locale('en'));
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _LanguageTogglePill(
                                label: 'বাংলা',
                                isSelected: context.watch<LanguageProvider>().isBangla,
                                isDark: isDark,
                                onTap: () {
                                  context.read<LanguageProvider>().setLocale(const Locale('bn', 'BD'));
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSettingsMenuItem(isDark: isDark, value: 6, icon: Icons.description_outlined, imageAssetPath: 'assets/icons/report.png', text: BanglaLocalizations.of(context).reports, ctx: ctx),
                  const SizedBox(height: 8),
                  _buildSettingsMenuItem(isDark: isDark, value: 8, icon: Icons.palette_outlined, imageAssetPath: 'assets/icons/customize-home.png', text: BanglaLocalizations.of(context).customizeHome, ctx: ctx),
                  const SizedBox(height: 8),
                  _buildSettingsMenuItem(isDark: isDark, value: 7, icon: Icons.notifications_none_outlined, imageAssetPath: 'assets/icons/notification.png', text: BanglaLocalizations.of(context).notifications, ctx: ctx),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsDropdown() {
    bool isActive = _currentIndex == 7 || _currentIndex == 6 || _isSettingsPanelOpen;
    return GestureDetector(
      onTap: () => _showSettingsPanel(context),
      child: _buildPillTabChild(7, Icons.settings_rounded, BanglaLocalizations.of(context).navSettings, isActive),
    );
  }

  Widget _buildSettingsMenuItem({required int value, required IconData icon, required String text, required bool isDark, required BuildContext ctx, String? imageAssetPath}) {
    return InkWell(
      onTap: () {
        if (Navigator.canPop(ctx)) {
          Navigator.pop(ctx, value);
        }
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.4),
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.2),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFCBD5E1).withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          children: [
            imageAssetPath != null
                ? Image.asset(
                    imageAssetPath,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  )
                : Icon(icon, size: 20, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Green indicator pill with a snake-molt feel: it squashes/stretches as it
  // travels and a glossy highlight sweeps across it like fresh new skin.
  Widget _buildMoltPill() {
    return AnimatedBuilder(
      animation: _navMoltController,
      builder: (context, child) {
        final double t = _navMoltController.value; // 0..1
        final double bump = math.sin(t * math.pi); // 0 -> 1 -> 0
        final double scaleX = 1.0 + 0.10 * bump;   // stretch along travel
        final double scaleY = 1.0 - 0.07 * bump;   // squash vertically
        // Glossy shine sweeps left -> right across the pill during travel
        final double shineX = -1.4 + t * 2.8;      // Alignment.x from -1.4..1.4
        final double shineOpacity = bump;          // brightest mid-travel

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF047857),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment(shineX, 0),
                  child: Opacity(
                    opacity: shineOpacity.clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: 0.4,
                      child: Container(
                        width: 26,
                        height: 90,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0x8CFFFFFF),
                              Color(0x00FFFFFF),
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
        );
      },
    );
  }

  Widget _buildFixedTab(int index, IconData icon, String label, {bool showLabel = true, Key? tabKey}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isActive = _currentIndex == index;

    // Active content is white (sits on the sliding green pill); inactive is green
    const Color activeTextColor = Colors.white;
    final Color inactiveTextColor = themeProvider.resolveColor(
      light: const Color(0xFF047857),
      dark: const Color(0xFF34D399),
    );
    // Idle border keeps the green outline; active border is hidden (pill fills it)
    final Color inactiveBorder = themeProvider.resolveColor(
      light: const Color(0xFF047857),
      dark: const Color(0xFF34D399),
    );

    Widget inner = Container(
      padding: EdgeInsets.symmetric(horizontal: showLabel ? 14 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isActive ? Colors.transparent : inactiveBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabIcon(index, icon, isActive),
          if (showLabel) const SizedBox(width: 6),
          if (showLabel)
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: isActive ? activeTextColor : inactiveTextColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.1,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      key: tabKey,
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: inner,
    );
  }

  // Used for Settings button and other independent tabs
  Widget _buildPillTabChild(int index, IconData icon, String label, bool isActive) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final Color activeBg = themeProvider.resolveColor(
      light: const Color(0xFF1E293B).withValues(alpha: 0.85),
      dark: Colors.white,
    );
    final Color inactiveBg = themeProvider.resolveColor(
      light: Colors.black.withValues(alpha: 0.08),
      dark: Colors.white.withValues(alpha: 0.08),
    );

    // Icon must contrast against its background in both states/themes.
    // Active bg: navy (light) / white (dark)  →  icon: white (light) / dark (dark)
    final Color activeIconColor = themeProvider.resolveColor(
      light: Colors.white,
      dark: const Color(0xFF282D37),
    );
    final Color inactiveIconColor = themeProvider.resolveColor(
      light: const Color(0xFF1E293B),
      dark: Colors.white,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? activeBg : inactiveBg,
          width: 1.0,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          icon,
          key: ValueKey<bool>(isActive),
          size: 16,
          color: isActive ? activeIconColor : inactiveIconColor,
        ),
      ),
    );
  }

  Widget _buildTabIcon(int index, IconData fallbackIcon, bool isActive) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String? assetPath;
    switch (index) {
      case 0: assetPath = 'assets/icons/dashboard.png'; break;
      case 1: assetPath = 'assets/icons/meals.png'; break;
      case 2: assetPath = 'assets/icons/member.png'; break;
      case 3: assetPath = 'assets/icons/expenses.png'; break;
      case 4: assetPath = 'assets/icons/payments.png'; break;
    }

    final activeColor = themeProvider.resolveColor(
      light: Colors.white,
      dark: Colors.white,
    );
    // Idle icon: visible in both themes (green on light, white on dark)
    final inactiveColor = themeProvider.resolveColor(
      light: const Color(0xFF047857),
      dark: Colors.white,
    );

    final Widget iconChild = assetPath != null
        ? Image.asset(
            assetPath,
            width: 16,
            height: 16,
            color: isActive ? activeColor : inactiveColor,
          )
        : Icon(
            fallbackIcon,
            color: isActive ? activeColor : inactiveColor,
            size: 16,
          );

    // Subtle icon pop when the tab becomes active
    return AnimatedScale(
      scale: isActive ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutBack,
      child: iconChild,
    );
  }
}

class HomeDashboardView extends StatefulWidget {
  const HomeDashboardView({super.key});

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  // Toggle states (default to true)
  bool showMealRate = true;
  bool showActiveMembers = true;
  bool showMealsToday = true;
  bool showTotalMeals = true;
  bool showTotalExpenses = true;
  bool showTotalPayments = true;
  bool showMealBalance = false;
  bool showShopDue = false;
  bool showFriedFine = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      showMealRate = prefs.getBool('show_meal_rate') ?? true;
      showActiveMembers = prefs.getBool('show_active_members') ?? true;
      showMealsToday = prefs.getBool('show_meals_today') ?? true;
      showTotalMeals = prefs.getBool('show_total_meals') ?? true;
      showTotalExpenses = prefs.getBool('show_total_expenses') ?? true;
      showTotalPayments = prefs.getBool('show_total_payments') ?? true;
      showMealBalance = prefs.getBool('show_meal_balance') ?? false;
      showShopDue = prefs.getBool('show_shop_due') ?? false;
      showFriedFine = prefs.getBool('show_fried_fine') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;

    // Calculate grid columns dynamically based on layout width
    int crossAxisCount = 2;
    double childAspectRatio = 1.35;

    if (isDesktop) {
      double availableWidth = screenWidth - 76 - 32; // Screen width minus sidebar
      if (availableWidth > 1400) {
        crossAxisCount = 6;
        childAspectRatio = 1.75;
      } else if (availableWidth > 1100) {
        crossAxisCount = 5;
        childAspectRatio = 1.65;
      } else if (availableWidth > 800) {
        crossAxisCount = 4;
        childAspectRatio = 1.55;
      } else {
        crossAxisCount = 3;
        childAspectRatio = 1.45;
      }
    } else {
      if (screenWidth > 600) {
        crossAxisCount = 3;
        childAspectRatio = 1.25;
      } else if (screenWidth < 360) {
        crossAxisCount = 1;
        childAspectRatio = 2.0; // Wide rectangular cards for tiny screens
      } else {
        crossAxisCount = 2;
        childAspectRatio = 1.18;
      }
    }

    final double hPadding = isDesktop ? 20.0 : 3.5;
    final double topPadding = isDesktop ? 100.0 : 20.0; // Clear the 85px cutout
    final topBar = _buildTopBar(context, screenWidth, isDesktop);

    return Scaffold(
      backgroundColor: Colors.transparent, // Blends into the parent beige panel
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: hPadding, right: hPadding, top: topPadding, bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topBar != null) ...[
              topBar,
              const SizedBox(height: 24),
            ],

            // Responsive Grid of 9 Cards (Optimized tighter gap for larger HUD cards)
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: isDesktop ? 16 : 8,
              mainAxisSpacing: isDesktop ? 16 : 8,
              childAspectRatio: childAspectRatio,
              children: _buildCards(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTopBar(BuildContext context, double screenWidth, bool isDesktop) {
    if (isDesktop) {
      return Align(
        alignment: Alignment.centerRight,
        child: Consumer<MessProvider>(
          builder: (context, provider, _) {
            return GestureDetector(
              onTap: () {
                ProfileDialog.show(context);
              },
              child: ProfileAvatar(
                radius: 18,
                customAvatarPath: provider.customAvatarPath,
              ),
            );
          },
        ),
      );
    }
    return null;
  }

  List<Widget> _buildCards(MessProvider provider) {
    final bn = BanglaLocalizations.of(context);
    List<Widget> cards = [];

    // ── Helper: clamp a ratio to [0.0, 1.0] and format as "XX%" ──────────
    double ratio(double value, double max) {
      if (max <= 0) return 0.0;
      return (value / max).clamp(0.0, 1.0);
    }
    String pct(double ratio) => '${(ratio * 100).round()}%';

    // ── Pre-calculate values needed across multiple cards ─────────────────
    final double totalMembers   = provider.totalActiveMembers.toDouble();
    final double todayMembers   = provider.todayActiveMembers.toDouble();
    final double totalMeals     = provider.totalMeals;
    final double mealsToday     = provider.mealsToday;
    final double totalExpenses  = provider.totalExpenses;
    final double totalPayments  = provider.totalPayments;
    final double shopDue        = provider.shopDue;
    final double friedFine      = provider.totalFriedFine;
    final double mealRate       = provider.mealRate;

    // Meal Balance = Payments - (totalMeals × mealRate) — same formula as summary
    // Positive = mess is in credit (members paid more than used)
    // Negative = members owe more
    final double mealBalance = totalPayments - (totalMeals * mealRate);

    // ── Progress ring logic ───────────────────────────────────────────────
    // Meal Rate: show how much of payments is consumed by cost
    //   ratio = totalCost / totalPayments  (how much of paid money is used up)
    final double mealRateProg = ratio(totalMeals * mealRate, totalPayments > 0 ? totalPayments : 1);

    // Active Members: today active / total active
    final double activeMembersProg = ratio(todayMembers, totalMembers > 0 ? totalMembers : 1);

    // Meals Today: today meals / (totalActive × 3 max possible meals today)
    final double maxPossibleMealsToday = totalMembers * 3;
    final double mealsTodayProg = ratio(mealsToday, maxPossibleMealsToday > 0 ? maxPossibleMealsToday : 1);

    // Total Meals: cumulative meals / (totalActive × daysElapsed × 3)
    final activeCycle = provider.billingCycles.firstWhere(
      (c) => c.id == provider.activeCycleId,
      orElse: () => BillingCycle(id: '', name: '', startDate: DateTime.now(), isActive: true),
    );
    final int daysElapsed = DateTime.now().difference(activeCycle.startDate).inDays + 1;
    final double maxPossibleMeals = totalMembers * daysElapsed * 3;
    final double totalMealsProg = ratio(totalMeals, maxPossibleMeals > 0 ? maxPossibleMeals : 1);

    // Expenses: how much of total payments has been spent as expenses
    final double expensesProg = ratio(totalExpenses, totalPayments > 0 ? totalPayments : 1);

    // Payments: payments collected vs estimated total cost
    //   estimated cost = totalMeals * mealRate (if >0) else just show against expenses
    final double estimatedCost = totalMeals * mealRate;
    final double paymentsProg = ratio(totalPayments, estimatedCost > 0 ? estimatedCost : (totalExpenses > 0 ? totalExpenses : 1));

    // Meal Balance: how balanced the mess is — |balance| / totalPayments
    //   0% ring = perfect balance, 100% = fully imbalanced
    //   We show "coverage" — what fraction of cost is covered by payments
    final double mealBalanceProg = estimatedCost > 0 ? ratio(totalPayments, estimatedCost) : 0.0;

    // Shop Due: due vs total expenses (how much is still unpaid to shops)
    final double shopDueProg = ratio(shopDue, totalExpenses > 0 ? totalExpenses : 1);

    // Fried+Fine: fine vs total expenses (proportion of fines)
    final double friedFineProg = ratio(friedFine, totalExpenses > 0 ? totalExpenses : 1);

    // ─────────────────────────────────────────────────────────────────────

    if (showMealRate) {
      cards.add(DashboardCard(
        title: bn.cardMealRate,
        icon: Icons.restaurant_rounded,
        iconAssetPath: 'assets/icons/meals.png',
        accentColor: const Color(0xFF3B82F6),
        progressValue: mealRateProg,
        progressLabel: pct(mealRateProg),
        content: SingleValueBox(
          value: '${provider.mealRate.toStringAsFixed(2)} - ৳',
          subLabel: '',
        ),
      ));
    }

    if (showActiveMembers) {
      cards.add(DashboardCard(
        title: bn.cardActiveMembers,
        icon: Icons.people_outline_rounded,
        iconAssetPath: 'assets/icons/member.png',
        accentColor: const Color(0xFF10B981),
        progressValue: activeMembersProg,
        progressLabel: pct(activeMembersProg),
        content: ActiveMembersBox(
          totalActive: provider.totalActiveMembers,
          todayActive: provider.todayActiveMembers,
        ),
      ));
    }

    if (showMealsToday) {
      cards.add(DashboardCard(
        title: bn.cardMealsToday,
        icon: Icons.lunch_dining_rounded,
        iconAssetPath: 'assets/icons/meals.png',
        accentColor: const Color(0xFFF59E0B),
        progressValue: mealsTodayProg,
        progressLabel: pct(mealsTodayProg),
        content: SingleValueBox(
          value: provider.mealsToday.toStringAsFixed(0),
          subLabel: '',
        ),
      ));
    }

    if (showTotalMeals) {
      cards.add(DashboardCard(
        title: bn.cardTotalMeals,
        icon: Icons.calendar_month_rounded,
        iconAssetPath: 'assets/icons/meals.png',
        accentColor: const Color(0xFFEC4899),
        progressValue: totalMealsProg,
        progressLabel: pct(totalMealsProg),
        content: SingleValueBox(
          value: provider.totalMeals.toStringAsFixed(1),
          subLabel: '',
        ),
      ));
    }

    if (showTotalExpenses) {
      cards.add(DashboardCard(
        title: bn.cardExpenses,
        icon: Icons.shopping_bag_rounded,
        iconAssetPath: 'assets/icons/expenses.png',
        accentColor: const Color(0xFF8B5CF6),
        progressValue: expensesProg,
        progressLabel: pct(expensesProg),
        content: SingleValueBox(
          value: '${provider.totalExpenses.toStringAsFixed(0)} - ৳',
          subLabel: '',
        ),
      ));
    }

    if (showTotalPayments) {
      cards.add(DashboardCard(
        title: bn.cardPayments,
        icon: Icons.credit_card_rounded,
        iconAssetPath: 'assets/icons/payments.png',
        accentColor: const Color(0xFF14B8A6),
        progressValue: paymentsProg,
        progressLabel: pct(paymentsProg),
        content: SingleValueBox(
          value: '${provider.totalPayments.toStringAsFixed(0)} - ৳',
          subLabel: '',
        ),
      ));
    }

    if (showMealBalance) {
      // Meal Balance: Payments - (Meals × MealRate)
      // Positive = surplus (members paid more than your bill)
      // Negative = deficit (members owe more)
      cards.add(DashboardCard(
        title: bn.cardMealBalance,
        icon: Icons.account_balance_wallet_rounded,
        iconAssetPath: 'assets/icons/dashboard.png',
        accentColor: mealBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        progressValue: mealBalanceProg,
        progressLabel: pct(mealBalanceProg),
        content: SingleValueBox(
          value: '${mealBalance.toStringAsFixed(0)} - ৳',
          subLabel: '',
        ),
      ));
    }

    if (showShopDue) {
      cards.add(DashboardCard(
        title: bn.cardShopDue,
        icon: Icons.storefront_rounded,
        iconAssetPath: 'assets/icons/expenses.png',
        accentColor: const Color(0xFF6B7280),
        progressValue: shopDueProg,
        progressLabel: pct(shopDueProg),
        content: SingleValueBox(
          value: '${provider.shopDue.toStringAsFixed(0)} - ৳',
          subLabel: '',
        ),
      ));
    }

    if (showFriedFine) {
      cards.add(DashboardCard(
        title: bn.cardFeastFines,
        icon: Icons.gavel_rounded,
        accentColor: const Color(0xFFEF4444),
        progressValue: friedFineProg,
        progressLabel: pct(friedFineProg),
        content: SingleValueBox(
          value: '${provider.totalFriedFine.toStringAsFixed(0)} - ৳',
          subLabel: '',
        ),
      ));
    }

    return cards;
  }
}

// Custom Clipper for Curved cardiology tab cutout style with fully rounded window edges
class TabCutoutClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double tabWidth = 280.0;
    final double curveWidth = 50.0;
    final double cutoutHeight = 85.0;
    final double cornerRadius = 28.0; // Roundness matching cardiology window bezel

    // Start on the left edge just below the top-left rounded corner
    path.moveTo(0, cornerRadius);
    
    // Top-Left Corner
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Go straight along the top tab edge
    path.lineTo(tabWidth, 0);

    // Smooth S-curve — like reference image corner
    path.cubicTo(
      tabWidth + curveWidth * 0.6, 0,           // control point 1 — stays near top
      tabWidth + curveWidth * 0.4, cutoutHeight, // control point 2 — pulls toward bottom
      tabWidth + curveWidth, cutoutHeight,       // end point
    );
    
    // Go straight along the lower top edge to the top-right corner
    path.lineTo(size.width - cornerRadius, cutoutHeight);
    
    // Top-Right Corner (starts at cutoutHeight, rounds into right edge)
    path.arcToPoint(
      Offset(size.width, cutoutHeight + cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Go straight down the right edge
    path.lineTo(size.width, size.height - cornerRadius);
    
    // Bottom-Right Corner
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Go straight along the bottom edge
    path.lineTo(cornerRadius, size.height);
    
    // Bottom-Left Corner
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Go straight up the left edge back to the start
    path.lineTo(0, cornerRadius);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


// ── Old painter kept so nothing else breaks (not used) ─────────────────────
class CurvedNavigationBarPainter extends CustomPainter {
  final double cx; // Center X of the active tab dip
  final Color color;

  CurvedNavigationBarPainter({required this.cx, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double radius = 24.0; // Corner radius matching top design in reference mockup
    final path = Path();
    
    // Start on the left edge just below the top-left rounded corner
    path.moveTo(0, 12 + radius);

    // Top-Left Corner
    path.arcToPoint(
      Offset(radius, 12),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    if (cx >= 0) {
      double rStart = radius;
      double rEnd = size.width - radius;

      double waveStartX = (cx - 50).clamp(rStart, rEnd);
      double cp1x = (cx - 38).clamp(rStart, rEnd);
      double cp2x = (cx - 34).clamp(rStart, rEnd);
      double cp3x = (cx - 24).clamp(rStart, rEnd);

      double cp4x = (cx - 16).clamp(rStart, rEnd);
      double cp5x = (cx - 14).clamp(rStart, rEnd);
      double cp6x = cx.clamp(rStart, rEnd);

      double cp7x = (cx + 14).clamp(rStart, rEnd);
      double cp8x = (cx + 16).clamp(rStart, rEnd);
      double cp9x = (cx + 24).clamp(rStart, rEnd);

      double cp10x = (cx + 34).clamp(rStart, rEnd);
      double cp11x = (cx + 38).clamp(rStart, rEnd);
      double waveEndX = (cx + 50).clamp(rStart, rEnd);

      path.lineTo(waveStartX, 12);

      // Curve 1: Flat top line to Left Peak of the hill (peaks at y = 0)
      path.cubicTo(cp1x, 12, cp2x, 0, cp3x, 0);

      // Curve 2: Left Peak to Saddle Bottom where the circle sits (dips to y = 18)
      path.cubicTo(cp4x, 0, cp5x, 18, cp6x, 18);

      // Curve 3: Saddle Bottom to Right Peak of the hill (peaks at y = 0)
      path.cubicTo(cp7x, 18, cp8x, 0, cp9x, 0);

      // Curve 4: Right Peak to Flat top line
      path.cubicTo(cp10x, 0, cp11x, 12, waveEndX, 12);
    }

    // Line to the start of top-right rounded corner
    path.lineTo(size.width - radius, 12);

    // Top-Right Corner
    path.arcToPoint(
      Offset(size.width, 12 + radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CurvedNavigationBarPainter oldDelegate) {
    return oldDelegate.cx != cx || oldDelegate.color != color;
  }
}

/// Lightweight data holder for bottom nav items.
class _NavItemData {
  final String label;
  final IconData icon;
  final String? assetPath;
  const _NavItemData(this.label, this.icon, this.assetPath);
}


class _SettingsShutterClipper extends CustomClipper<Path> {
  final double cornerRadius;
  _SettingsShutterClipper(this.cornerRadius);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(cornerRadius),
      ));
  }

  @override
  bool shouldReclip(_SettingsShutterClipper oldClipper) => oldClipper.cornerRadius != cornerRadius;
}

class AnimatedGreetingsHeader extends StatefulWidget {
  const AnimatedGreetingsHeader({super.key});

  @override
  State<AnimatedGreetingsHeader> createState() => _AnimatedGreetingsHeaderState();
}

class _AnimatedGreetingsHeaderState extends State<AnimatedGreetingsHeader> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {                  return BanglaLocalizations.of(context).greetingMorning;
    } else if (hour >= 12 && hour < 17) {                  return BanglaLocalizations.of(context).greetingAfternoon;
    } else if (hour >= 17 && hour < 22) {                  return BanglaLocalizations.of(context).greetingEvening;
    } else {                  return BanglaLocalizations.of(context).greetingNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(left: 50.0, top: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  BanglaLocalizations.of(context).appTitle,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12, // Restored back to readable size outside card
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer<MessProvider>(
              builder: (context, provider, _) {
                final userName = provider.currentUser.name;
                final greeting = _getGreeting();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${greeting.toUpperCase()}, ${userName.toUpperCase()}",
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7.5, // Restored back to readable size
                        color: isDark ? Colors.white54 : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "👋",
                      style: TextStyle(
                        fontSize: 14, // Restored emoji size
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class FolderPath {
  static Path getPath(Size size, double tabWidth, double tabHeight, double cornerRadius, double curveWidth) {
    final Path path = Path();
    
    // Start at bottom left of the tab / top left of the body
    path.moveTo(0, tabHeight + cornerRadius);
    
    // Top-left of the tab
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    // Top-right of the tab
    path.lineTo(tabWidth - cornerRadius, 0);
    path.quadraticBezierTo(tabWidth, 0, tabWidth, cornerRadius);
    
    // Smooth cubic S-Curve transition down to the body top edge
    path.cubicTo(
      tabWidth + curveWidth * 0.4, 0.0, // control point 1
      tabWidth + curveWidth * 0.6, tabHeight, // control point 2
      tabWidth + curveWidth, tabHeight // end point
    );
    
    // Top-right of the body
    path.lineTo(size.width - cornerRadius, tabHeight);
    path.quadraticBezierTo(size.width, tabHeight, size.width, tabHeight + cornerRadius);
    
    // Bottom-right of the body
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    
    // Bottom-left of the body
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    
    path.close();
    return path;
  }
}

class FolderShapePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double tabWidth;
  final double tabHeight;
  final double borderWidth;

  FolderShapePainter({
    required this.fillColor,
    required this.borderColor,
    required this.tabWidth,
    required this.tabHeight,
    this.borderWidth = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Path path = FolderPath.getPath(size, tabWidth, tabHeight, 6.0, 10.0);
    canvas.drawPath(path, paint);

    if (borderColor != Colors.transparent && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FolderShapePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.tabWidth != tabWidth ||
        oldDelegate.tabHeight != tabHeight ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class FolderCard extends StatelessWidget {
  final Widget child;
  final bool isHovered;
  final Color backgroundColor;
  final Color borderColor;
  final double width;
  final double height;
  final double tabWidth;
  final double tabHeight;

  const FolderCard({
    super.key,
    required this.child,
    required this.isHovered,
    required this.backgroundColor,
    required this.borderColor,
    this.width = 256,
    this.height = 62,
    this.tabWidth = 92,
    this.tabHeight = 15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0xFF0F172A).withValues(alpha: 0.12);
    final double offset = isHovered ? 4 : 2;

    return Stack(
      children: [
        // 1. Flat hard offset shadow path
        Transform.translate(
          offset: Offset(0, offset),
          child: CustomPaint(
            size: Size(width, height),
            painter: FolderShapePainter(
              fillColor: shadowColor,
              borderColor: Colors.transparent,
              tabWidth: tabWidth,
              tabHeight: tabHeight,
            ),
          ),
        ),
        // 2. The main folder card with border
        CustomPaint(
          size: Size(width, height),
          painter: FolderShapePainter(
            fillColor: backgroundColor,
            borderColor: borderColor,
            tabWidth: tabWidth,
            tabHeight: tabHeight,
            borderWidth: 1.5,
          ),
          child: Stack(
            children: [
              // Tab label text
              Positioned(
                left: 10,
                top: 3,
                child: Text(
                  BanglaLocalizations.of(context).controlPanel,
                  style: TextStyle(
                    fontSize: 7.0,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E3A8A),
                    letterSpacing: 0.8,
                    ),
                ),
              ),
              // Body content
              Container(
                width: width,
                height: height,
                padding: EdgeInsets.only(top: tabHeight + 4, left: 10, right: 10, bottom: 4),
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CurvedPanelPainter extends CustomPainter {
  final Color fillColor;
  final Gradient? gradient;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffset;
  final Color shadowColor;

  CurvedPanelPainter({
    required this.fillColor,
    this.gradient,
    required this.borderColor,
    this.borderWidth = 1.5,
    this.shadowOffset = 0.0,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = TabCutoutClipper().getClip(size);

    // 1. Draw flat shadow first
    if (shadowOffset > 0 && shadowColor != Colors.transparent) {
      final shadowPaint = Paint()
        ..color = shadowColor
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(0, shadowOffset);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    // 2. Draw fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill;
    
    if (gradient != null) {
      fillPaint.shader = gradient!.createShader(Offset.zero & size);
    } else {
      fillPaint.color = fillColor;
    }
    
    canvas.drawPath(path, fillPaint);

    // 3. Draw border
    if (borderColor != Colors.transparent && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CurvedPanelPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.gradient != gradient ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.shadowOffset != shadowOffset ||
        oldDelegate.shadowColor != shadowColor;
  }
}

class _LanguageTogglePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageTogglePill({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF134E4A) : const Color(0xFF0D9488))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.4)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[300] : const Color(0xFF475569)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


class _NeumorphicSwitch extends StatelessWidget {
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color glowColor;

  const _NeumorphicSwitch({
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF090D16) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 44 : 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242E42) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: isActive
                    ? Text(
                        'On',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? iconColor : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

