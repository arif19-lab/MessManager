import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/bangla_localizations.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';
import '../widgets/glass_dialog.dart';

class GuestMealsScreen extends StatefulWidget {
  const GuestMealsScreen({super.key});

  @override
  State<GuestMealsScreen> createState() => _GuestMealsScreenState();
}

class _GuestMealsScreenState extends State<GuestMealsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bn = BanglaLocalizations.of(context);
    final provider = Provider.of<MessProvider>(context);
    final allMembers = provider.allMembers;
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final guestMealsForDate = provider.getGuestMealsForDate(dateString);
    final totalGuestCount = guestMealsForDate.fold<int>(0, (s, g) => s + g.count);

    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate guest cost at current meal rate
    final mealRate = provider.mealRate;

    // Build list of members who have guest meals on this date — like Fried Fine only shows members with fines
    final memberIds = guestMealsForDate.map((g) => g.memberId).toSet();
    final List<Member> guestMembers = memberIds.map((id) {
      final member = allMembers.firstWhere(
        (m) => m.id == id,
        orElse: () => Member(id: id, name: id, email: '', imageUrl: '', isActive: false),
      );
      final count = guestMealsForDate
          .where((g) => g.memberId == id)
          .fold<int>(0, (sum, item) => sum + item.count);
      return member.copyWith(guestMeals: count.toDouble());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          bn.guestMealsTitle,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: isDesktop ? 20.0 : 10.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: themeProvider.resolveColor(
                                light: Colors.white,
                                dark: const Color(0xFF0A0A0A),
                              ),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              bn.guestMealsTitle,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Date badge
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: themeProvider.resolveColor(
                                  light: Colors.white,
                                  dark: const Color(0xFF0A0A0A),
                                ),
                                border: Border.all(
                                    color: const Color(0xFF0D9488)
                                        .withValues(alpha: 0.6),
                                    width: 1.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 14,
                                      color: const Color(0xFF0D9488)),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM')
                                        .format(_selectedDate),
                                    style: const TextStyle(
                                      color: Color(0xFF0D9488),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Right: "Add Guest" desktop button + Total pill
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDesktop) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFF10B981),
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _showAddGuestDialog(context, provider, dateString),
                                borderRadius: BorderRadius.circular(30),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_add_alt_1,
                                          color: const Color(0xFF10B981),
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        bn.addGuest,
                                        style: TextStyle(
                                          color: const Color(0xFF10B981),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: themeProvider.resolveColor(
                                light: Colors.white,
                                dark: const Color(0xFF0A0A0A),
                              ),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              totalGuestCount > 0
                                  ? 'Total = $totalGuestCount'
                                  : bn.noGuests,
                              style: TextStyle(
                                color: totalGuestCount > 0
                                    ? const Color(0xFF0D9488)
                                    : (isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Cost summary row (only when guests exist)
                  if (totalGuestCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            '${bn.guestMealRate} ${mealRate.toStringAsFixed(2)} - Tk',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          // Clear all button
                          GestureDetector(
                            onTap: () => _confirmClearAll(
                                context, provider, dateString),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.delete_rounded,
                                      size: 12,
                                      color: const Color(0xFFEF4444)),
                                  const SizedBox(width: 4),
                                  Text(
                                    bn.clearAll,
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 3. Guest member cards list (only members with guests > 0)
                  Expanded(
                    child: guestMembers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_alt_1,
                                    size: 48,
                                    color: isDark ? Colors.grey[600] : Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  bn.noGuestMeals,
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bn.clickAddGuest,
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            padding: EdgeInsets.only(
                                bottom:
                                    isDesktop ? 24 : (100 + bottomPadding)),
                            itemCount: guestMembers.length,
                            itemBuilder: (context, index) {
                              final member = guestMembers[index];
                              return _buildMemberCard(
                                  context, provider, member, dateString,
                                  isDark, themeProvider);
                            },
                          ),
                  ),
                ],
              ),
            ),

            // 4. Mobile: Add Guest FAB
            if (!isDesktop)
              Positioned(
                bottom: 32 + bottomPadding,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0A0A0A).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _showAddGuestDialog(context, provider, dateString),
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1,
                                color: const Color(0xFF10B981), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              bn.addGuest,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MessProvider provider,
      Member member, String dateString, bool isDark, ThemeProvider themeProvider) {
    final guestCount =
        provider.getGuestMealCountForMember(member.id, dateString);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.resolveColor(
          light: Colors.white,
          dark: const Color(0xFF0A0A0A),
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF0D9488).withValues(alpha: 0.6),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor:
                isDark ? const Color(0xFF065F46).withValues(alpha: 0.7)
                    : const Color(0xFF86EFAC).withValues(alpha: 0.4),
            child: Text(
              member.name.isNotEmpty
                  ? member.name.substring(0, 1).toUpperCase()
                  : '?',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF065F46),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.35)),
              ),
              child: Text(
                member.name,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Guest count controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus button
              GestureDetector(
                onTap: () {
                  if (guestCount > 1) {
                    provider.setGuestMealForMember(
                        member.id, dateString, guestCount - 1);
                    HapticFeedback.lightImpact();
                  }
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: guestCount > 0
                        ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: guestCount > 0
                          ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: guestCount > 0
                        ? const Color(0xFFEF4444)
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Count
              SizedBox(
                width: 28,
                child: Text(
                  '$guestCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: guestCount > 0
                        ? const Color(0xFF0D9488)
                        : (isDark
                            ? Colors.grey[400]
                            : const Color(0xFF475569)),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // Plus button
              GestureDetector(
                onTap: () {
                  if (guestCount < 9) {
                    provider.setGuestMealForMember(
                        member.id, dateString, guestCount + 1);
                    HapticFeedback.lightImpact();
                  }
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Clear button — with confirmation dialog
              GestureDetector(
                onTap: () {
                  _confirmClearMember(
                      context, provider, member, dateString);
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── "Add Guest" Dialog (like Add Fine dialog) ───────────────────────
  void _showAddGuestDialog(
      BuildContext context, MessProvider provider, String dateString) {
    final allActiveMembers = provider.members.where((m) => m.isActive).toList();
    String? selectedMemberId =
        allActiveMembers.isNotEmpty ? allActiveMembers[0].id : null;
    int guestCount = 1;

    showGlassDialog(
      context: context,
      builder: (context) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.resolveColor(
                      light: Colors.white,
                      dark: const Color(0xFF0A0A0A),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BanglaLocalizations.of(context).addGuestMeal,
                        style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Guest count selector with +/- buttons
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      const Color(0xFF0D9488).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    BanglaLocalizations.of(context).guestCount,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (guestCount > 1) {
                                            setDialogState(() {
                                              guestCount--;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFFEF4444)
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Color(0xFFEF4444),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$guestCount',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0D9488),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          if (guestCount < 9) {
                                            setDialogState(() {
                                              guestCount++;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFF10B981)
                                                  .withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xFF10B981),
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Member',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(
                                context, allActiveMembers,
                                selectedMemberId, (val) {
                              setDialogState(() {
                                selectedMemberId = val;
                              });
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedMemberId == null) return;
                              final member = allActiveMembers.firstWhere(
                                  (m) => m.id == selectedMemberId);
                              provider.setGuestMealForMember(
                                  selectedMemberId!, dateString, guestCount);
                              Navigator.pop(context);
                              GlassyNotification.show(context,
                                  message:
                                      'Added $guestCount guest meal(s) to ${member.name}.');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: Text(BanglaLocalizations.of(context).save,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Member selector list widget ──────────────────────────────────
  Widget _buildMemberSelectorList(BuildContext context,
      List<Member> members, String? selectedId, ValueChanged<String> onSelected) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final m = members[index];
          bool isSelected = m.id == selectedId;
          return InkWell(
            onTap: () => onSelected(m.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0D9488)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : (isDark
                            ? const Color(0xFF065F46).withValues(alpha: 0.5)
                            : const Color(0xFF86EFAC)
                                .withValues(alpha: 0.4)),
                    child: Text(
                      m.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : const Color(0xFF065F46)),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    m.name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? Colors.white70
                              : const Color(0xFF1E293B)),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Date picker dialog ──────────────────────────────────────────────
  void _selectDate(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode;

    showGlassDialog(
      context: context,
      builder: (context) {
        DateTime tempDate = _selectedDate;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.resolveColor(
                      light: Colors.white,
                      dark: const Color(0xFF0A0A0A),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey[700]!
                          : Colors.grey.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          BanglaLocalizations.of(context).selectDate,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: CalendarDatePicker(
                          initialDate: tempDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          onDateChanged: (date) {
                            setDialogState(() {
                              tempDate = date;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(BanglaLocalizations.of(context).cancel,
                                style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = tempDate;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            child: Text(BanglaLocalizations.of(context).select,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Clear member confirm dialog ────────────────────────────────────
  void _confirmClearMember(BuildContext context, MessProvider provider,
      Member member, String dateString) {
    final themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode;
    final guestCount =
        provider.getGuestMealCountForMember(member.id, dateString);

    showGlassDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                width: 1.5,
              )),
          title: Text(
            'Clear Guest',
            style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to remove $guestCount guest meal(s) for ${member.name}?',
            style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
                fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(BanglaLocalizations.of(context).cancel,
                  style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.setGuestMealForMember(
                    member.id, dateString, 0);
                Navigator.pop(context);
                GlassyNotification.show(context,
                    message:
                        'Cleared guest for ${member.name}.');
              },
              child: Text(BanglaLocalizations.of(context).remove,
                  style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ─── Clear all confirm dialog ────────────────────────────────────────
  void _confirmClearAll(
      BuildContext context, MessProvider provider, String dateString) {
    final themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode;

    showGlassDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                width: 1.5,
              )),
          title: Text(
            'Clear All Guests',
            style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to clear all guest meals for ${DateFormat('dd MMM yyyy').format(_selectedDate)}?',
            style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
                fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(BanglaLocalizations.of(context).cancel,
                  style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.clearAllGuestMealsForDate(dateString);
                Navigator.pop(context);
                GlassyNotification.show(context,
                    message: 'Cleared all guest meals.');
              },
              child: Text(BanglaLocalizations.of(context).clearAll,
                  style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
