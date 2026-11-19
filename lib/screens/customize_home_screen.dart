import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/bangla_localizations.dart';

class CustomizeHomeScreen extends StatefulWidget {
  const CustomizeHomeScreen({super.key});

  @override
  State<CustomizeHomeScreen> createState() => _CustomizeHomeScreenState();
}

class _CustomizeHomeScreenState extends State<CustomizeHomeScreen> {
  // Toggle states
  bool showMealRate = true;
  bool showActiveMembers = true;
  bool showMealsToday = true;
  bool showTotalMeals = true;
  bool showTotalExpenses = true;
  bool showTotalPayments = true;
  bool showShopDue = false;
  bool showFriedFine = false;
  bool showMealBalance = false;

  // System UI
  bool fullscreenMode = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
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
      fullscreenMode = prefs.getBool('fullscreen_mode') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_meal_rate', showMealRate);
    await prefs.setBool('show_active_members', showActiveMembers);
    await prefs.setBool('show_meals_today', showMealsToday);
    await prefs.setBool('show_total_meals', showTotalMeals);
    await prefs.setBool('show_total_expenses', showTotalExpenses);
    await prefs.setBool('show_total_payments', showTotalPayments);
    await prefs.setBool('show_meal_balance', showMealBalance);
    await prefs.setBool('show_shop_due', showShopDue);
    await prefs.setBool('show_fried_fine', showFriedFine);
    await prefs.setBool('fullscreen_mode', fullscreenMode);

    if (mounted) {
      Navigator.pop(context, true); // Return true to signal a refresh is needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    bool isDesktop = MediaQuery.of(context).size.width > 850;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
      body: const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488))),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          BanglaLocalizations.of(context).customizeHome,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488), // Teal color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              ),
              child: Text(
                BanglaLocalizations.of(context).save,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                BanglaLocalizations.of(context).selectCardsToShow,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // ── Fullscreen Toggle Section (Mobile Only) ──
              if (!isDesktop) ...[
                _buildSectionLabel(BanglaLocalizations.of(context).system, isDark),
                const SizedBox(height: 12),
                _buildRowToggle(
                  icon: Icons.fullscreen_rounded,
                  title: BanglaLocalizations.of(context).fullScreenMode,
                  subtitle: BanglaLocalizations.of(context).hideStatusBars,
                  value: fullscreenMode,
                  isDark: isDark,
                  onChanged: (val) => setState(() => fullscreenMode = val),
                ),
                const SizedBox(height: 28),
              ],

              // ── Dashboard Cards Section ──
              _buildSectionLabel(BanglaLocalizations.of(context).dashboardCards, isDark),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Mobile: 2 col, Desktop: auto 4–5 col based on width
                  final isDesktop = constraints.maxWidth > 600;
                  final cols = isDesktop
                      ? (constraints.maxWidth / 180).floor().clamp(3, 5)
                      : 2;

                  return GridView.count(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildToggleCard(BanglaLocalizations.of(context).cardMealRate,       showMealRate,       (v) => setState(() => showMealRate       = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardActiveMembers,  showActiveMembers,  (v) => setState(() => showActiveMembers  = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardMealsToday,     showMealsToday,     (v) => setState(() => showMealsToday     = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardTotalMeals,     showTotalMeals,     (v) => setState(() => showTotalMeals     = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardExpenses,  showTotalExpenses,  (v) => setState(() => showTotalExpenses  = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardPayments,  showTotalPayments,  (v) => setState(() => showTotalPayments  = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardMealBalance,    showMealBalance,    (v) => setState(() => showMealBalance    = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardShopDue,        showShopDue,        (v) => setState(() => showShopDue        = v), isDark),
                      _buildToggleCard(BanglaLocalizations.of(context).cardFeastFines,   showFriedFine,      (v) => setState(() => showFriedFine      = v), isDark),
                    ],
                  );
                },
              ),

              // (Language section moved to desktop settings panel)

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        color: const Color(0xFF0D9488),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRowToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF0F172A).withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D9488).withValues(alpha: 0.2) : const Color(0xFF0D9488).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(
                  color: isDark ? Colors.grey[500] : const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
              ],
            ),
          ),
          _TogglePill(value: value, isDark: isDark, onChanged: onChanged),
        ],
      ),
    );
  }

  /// Border-only box: title → gap → toggle pill. No background fill.
  Widget _buildToggleCard(String title, bool value, Function(bool) onChanged, bool isDark) {
    final bool isOn = value;
    final Color borderColor = isOn
        ? const Color(0xFF0D9488)                                          // teal when ON
        : (isDark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.12));                       // subtle when OFF

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,                                        // NO fill
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isOn ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _TogglePill(value: value, isDark: isDark, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatefulWidget {
  final bool value;
  final bool isDark;
  final Function(bool) onChanged;

  const _TogglePill({required this.value, required this.isDark, required this.onChanged});

  @override
  State<_TogglePill> createState() => _TogglePillState();
}

class _TogglePillState extends State<_TogglePill> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Container(
        width: 80,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF090D16) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF242E42) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Text(
                  widget.value ? BanglaLocalizations.of(context).onLabel : BanglaLocalizations.of(context).offLabel,
                  style: TextStyle(
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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

