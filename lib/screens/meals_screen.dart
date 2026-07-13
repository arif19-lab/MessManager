import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';
import '../widgets/glass_dialog.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  DateTime _selectedDate = DateTime.now();
  int _guestMeals = 0;
  
  // Track Breakfast, Lunch, Dinner states locally
  final Map<String, Map<String, bool>> _mealsState = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessProvider>(context);
    final allActiveMembers = provider.members.where((m) => m.isActive).toList();
    final activeMembers = allActiveMembers;
    final String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Sync _mealsState from provider's persistent dailyMeals list for the selected date and active cycle
    for (var m in activeMembers) {
      final dm = provider.dailyMeals.firstWhere(
        (item) => item.memberId == m.id && item.dateString == dateString && item.cycleId == provider.activeCycleId,
        orElse: () => DailyMeal(id: '', memberId: m.id, dateString: dateString, cycleId: provider.activeCycleId),
      );
      _mealsState[m.id] = {
        'B': dm.breakfast,
        'L': dm.lunch,
        'D': dm.dinner,
      };
    }

    // Calculations based on daily meal states
    int eatingTodayCount = activeMembers.where((m) {
      final state = _mealsState[m.id];
      if (state == null) return false;
      return state['B']! || state['L']! || state['D']!;
    }).length;

    int totalActiveCount = activeMembers.length;

    // Check if all active members have B, L, and D checked
    bool isAllMarked = activeMembers.isNotEmpty && activeMembers.every((m) {
      final state = _mealsState[m.id];
      if (state == null) return false;
      return state['B']! && state['L']! && state['D']!;
    });

    double totalMealsCountToday = _guestMeals.toDouble();
    for (var m in activeMembers) {
      final state = _mealsState[m.id];
      if (state != null) {
        totalMealsCountToday += (state['B']! ? 1.0 : 0.0) +
            (state['L']! ? 1.0 : 0.0) +
            (state['D']! ? 1.0 : 0.0);
      }
    }

    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent, // Blends into home_screen beige
      body: Padding(
        padding: EdgeInsets.only(
          left: isDesktop ? 32.0 : 16.0,
          right: isDesktop ? 32.0 : 16.0,
          top: isDesktop ? 100.0 : 24.0,
          bottom: 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Text(
                'Daily Meals Tracker',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track and mark daily active meals for all mess members',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 1. Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStatBox(
                  title: 'Eating / Active Today',
                  value: '$eatingTodayCount/$totalActiveCount',
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  title: 'Total Meals Today',
                  value: 'Total = ${totalMealsCountToday % 1 == 0 ? totalMealsCountToday.toInt().toString() : totalMealsCountToday.toString()}',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Action Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildActionButton(
                  icon: Icons.calendar_today_rounded,
                  label: DateFormat('dd MMM').format(_selectedDate),
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.45),
                  textColor: isDark ? Colors.white : const Color(0xFF334155),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2), width: 1.5),
                  onTap: () {
                    _showCustomDatePicker();
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.add_circle_outline_rounded,
                  label: _guestMeals > 0 ? 'Guest Meal ($_guestMeals)' : 'Guest Meal',
                  color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFF10B981).withValues(alpha: 0.08),
                  textColor: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.5),
                  onTap: () {
                    _showGuestMealDialog();
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: isAllMarked ? Icons.close_rounded : Icons.done_all_rounded,
                  label: isAllMarked ? 'Unmark All' : 'Mark All',
                  color: isAllMarked
                      ? const Color(0xFFEF4444)
                      : (isDark ? const Color(0xFFEF4444).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.08)),
                  textColor: isAllMarked ? Colors.white : (isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B)),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5), width: 1.5),
                  onTap: () {
                    provider.toggleAllDailyMeals(
                      activeMembers.map((m) => m.id).toList(),
                      dateString,
                      !isAllMarked,
                    );
                    GlassyNotification.show(
                      context, 
                      message: isAllMarked ? 'Unmarked all meals successfully!' : 'Marked all meals successfully!'
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Active Members List',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 3. Members List view
            Expanded(
              child: activeMembers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'No members yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.only(bottom: isDesktop ? 24 : (100 + bottomPadding)),
                      itemCount: activeMembers.length,
                      itemBuilder: (context, index) {
                        final member = activeMembers[index];
                        final meals = _mealsState[member.id] ?? {'B': false, 'L': false, 'D': false};
                        return _buildMemberCard(context, provider, member, meals, isDark, dateString);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Border? border,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MessProvider provider, var member, Map<String, bool> meals, bool isDark, String dateString) {
    double memberTotalMeals = (meals['B']! ? 1.0 : 0.0) +
        (meals['L']! ? 1.0 : 0.0) +
        (meals['D']! ? 1.0 : 0.0);
    
    bool isEatingToday = memberTotalMeals > 0.0;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: themeProvider.resolveColor(
          light: Colors.white,
          dark: const Color(0xFF0A0A0A),
            ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEatingToday ? const Color(0xFF0D9488) : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.24)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? const Color(0xFF065F46).withValues(alpha: 0.7) : const Color(0xFF86EFAC).withValues(alpha: 0.4),
            child: Text(
              member.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF065F46),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.35)),
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
          
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF1F1F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              bool allChecked = meals['B']! && meals['L']! && meals['D']!;
                              provider.toggleDailyMeal(member.id, dateString, 'B', !allChecked);
                              provider.toggleDailyMeal(member.id, dateString, 'L', !allChecked);
                              provider.toggleDailyMeal(member.id, dateString, 'D', !allChecked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : const Color(0xFFE2E2F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'All',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF555578),
                                ),
                              ),
                            ),
                          ),
                          
                          _buildMealCheckbox('B', meals, isDark, (val) {
                            provider.toggleDailyMeal(member.id, dateString, 'B', val);
                          }),
                          
                          _buildMealCheckbox('L', meals, isDark, (val) {
                            provider.toggleDailyMeal(member.id, dateString, 'L', val);
                          }),
                          
                          _buildMealCheckbox('D', meals, isDark, (val) {
                            provider.toggleDailyMeal(member.id, dateString, 'D', val);
                          }),
                          
                          Container(
                            width: 26,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : const Color(0xFFDDDDF2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              memberTotalMeals % 1 == 0
                                  ? memberTotalMeals.toInt().toString()
                                  : memberTotalMeals.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF4A4A68),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCheckbox(String label, Map<String, bool> meals, bool isDark, ValueChanged<bool> onChanged) {
    bool isChecked = meals[label]!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[400] : const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => onChanged(!isChecked),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isDark ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isChecked ? const Color(0xFF0D9488) : Colors.grey.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Color(0xFF0D9488), size: 12)
                : null,
          ),
        ),
      ],
    );
  }

  void _showCustomDatePicker() {
    showGlassDialog(
      context: context,
      builder: (context) {
        return CustomDatePickerDialog(
          initialDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        );
      },
    );
  }

  void _showGuestMealDialog() {
    int tempGuestCount = _guestMeals;
    showGlassDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final themeProvider = Provider.of<ThemeProvider>(context);
            bool isDark = themeProvider.isDarkMode;
            return AlertDialog(
                backgroundColor: themeProvider.resolveColor(
                  light: Colors.white,
                  dark: const Color(0xFF0A0A0A),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  'Manage Guest Meals',
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Specify the number of extra/guest meals to add for today.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (tempGuestCount > 0) {
                            setDialogState(() => tempGuestCount--);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 28),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          '$tempGuestCount',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() => tempGuestCount++);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 28),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _guestMeals = tempGuestCount;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  final List<String> _weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstWeekdayOffset(DateTime date) {
    int weekday = DateTime(date.year, date.month, 1).weekday;
    return weekday == 7 ? 0 : weekday;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDark = themeProvider.isDarkMode;
    
    int daysCount = _getDaysInMonth(_focusedMonth);
    int offset = _getFirstWeekdayOffset(_focusedMonth);
    int totalCells = daysCount + offset;

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
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.withValues(alpha: 0.12)),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B), size: 22),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 22),
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekDays.map((day) {
                  return Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < offset) {
                    return const SizedBox();
                  }
                  
                  final dayNumber = index - offset + 1;
                  final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                  
                  bool isSelected = _selectedDate.year == cellDate.year &&
                      _selectedDate.month == cellDate.month &&
                      _selectedDate.day == cellDate.day;
                      
                  bool isToday = DateTime.now().year == cellDate.year &&
                      DateTime.now().month == cellDate.month &&
                      DateTime.now().day == cellDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = cellDate;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isToday && !isSelected
                            ? Border.all(color: const Color(0xFF0D9488), width: 1.5)
                            : null,
                      ),
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isToday ? const Color(0xFF0D9488) : (isDark ? Colors.white : const Color(0xFF1E293B))),
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onDateSelected(_selectedDate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Select',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
