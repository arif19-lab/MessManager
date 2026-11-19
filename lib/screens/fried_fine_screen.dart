import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import '../widgets/glass_dialog.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';
import '../l10n/bangla_localizations.dart';
import 'guest_meals_screen.dart';

class FriedFineScreen extends StatelessWidget {
  const FriedFineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessProvider>(context);
    final cycleItems = provider.friedFineItems;
    final allMembers = provider.allMembers;
    
    final totalFines = provider.totalFriedFine;
    // Build card list from items: include every member who has items in current cycle,
    // even if they're not in the filtered members list
    final memberIds = cycleItems.map((f) => f.memberId).toSet();
    final List<Member> activeMembers = memberIds.map((id) {
      final member = allMembers.firstWhere(
        (m) => m.id == id,
        orElse: () => Member(id: id, name: id, email: '', imageUrl: '', isActive: false),
      );
      final total = cycleItems
          .where((f) => f.memberId == id)
          .fold(0.0, (sum, item) => sum + item.amount);
      return member.copyWith(friedFine: total);
    }).toList();

    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          BanglaLocalizations.of(context).feastAndFines,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: isDesktop ? 100.0 : 20.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Badges (responsive layout)
                  if (isDesktop)                        // Desktop: horizontal scrollable row (title now in AppBar)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildGuestButton(context),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                width: 1.5,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                _showAddFriedFineDialog(context, provider);
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      BanglaLocalizations.of(context).addFine,
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
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
                          _buildTotalPill(context, themeProvider, isDark, totalFines),
                        ],
                      ),
                    )
                  else
                    // Mobile: Guest + Total below the AppBar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildGuestButton(context),
                          const SizedBox(width: 12),
                          _buildTotalPill(context, themeProvider, isDark, totalFines),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // 2. Active member cards list
                  Expanded(
                    child: activeMembers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  BanglaLocalizations.of(context).noRecordsFound,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  BanglaLocalizations.of(context).clickAddFine,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
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
                              return _buildMemberFineCard(context, provider, member);
                            },
                          ),
                  ),

                ],
              ),
            ),

            // 3. Black Bottom FAB: "Add Fine"
            if (!isDesktop)
              Positioned(
                bottom: 120 + bottomPadding,
                right: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF34D399).withValues(alpha: 0.15)
                            : const Color(0xFF047857).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _showAddFriedFineDialog(context, provider);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), size: 18),
                            const SizedBox(width: 8),                              Text(
                                BanglaLocalizations.of(context).addFine,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
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

  Widget _buildGuestButton(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GuestMealsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add_alt_1,
                size: 18,
                color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
              ),
              const SizedBox(width: 8),
              Text(
                BanglaLocalizations.of(context).guest,
                style: TextStyle(
                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalPill(BuildContext context, ThemeProvider themeProvider, bool isDark, double totalFines) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.resolveColor(
          light: Colors.white,
          dark: const Color(0xFF0A0A0A),
        ),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Total = ${totalFines.toInt()}',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMemberFineCard(BuildContext context, MessProvider provider, Member member) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Get all fine items for this member
    final memberFines = provider.friedFineItems.where((item) => item.memberId == member.id).toList();

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.resolveColor(
          light: Colors.white,
          dark: const Color(0xFF0A0A0A),
            ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Theme.of(context).colorScheme.onSurface.withValues(alpha: member.isActive ? 0.25 : 0.12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Member Name, Total, Delete Card Button
          Row(
            children: [
              // 1. Avatar (Mint/light-green circle avatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? const Color(0xFF065F46).withValues(alpha: 0.7) : const Color(0xFF86EFAC).withValues(alpha: 0.4),
                child: Text(
                  member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF065F46),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Rounded Name Container
              Container(
                width: 85,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.35)),
                ),
                child: Text(
                  member.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ':',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // 3. Right Section: Total and delete button
              Row(
                children: [
                  Text(
                    '= ${member.friedFine.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF0D9488), // Green
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      _showClearConfirmDialog(context, provider, member);
                    },
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Amounts header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                BanglaLocalizations.of(context).amounts,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showAddFineForMemberDialog(context, provider, member);
                },
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal scroll of fine pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: memberFines.map((item) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5), // Mint green
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${item.amount.toInt()}',
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          _showDeletePillConfirmDialog(context, provider, item);
                        },
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Color(0xFF047857),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelectorList(BuildContext context, List<Member> members, String? selectedId, ValueChanged<String> onSelected) {
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
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : (isDark ? const Color(0xFF065F46).withValues(alpha: 0.5) : const Color(0xFF86EFAC).withValues(alpha: 0.4)),
                    child: Text(
                      m.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF065F46)),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    m.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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

  void _showAddFriedFineDialog(BuildContext context, MessProvider provider) {
    final amountController = TextEditingController();
    String? selectedMemberId = provider.members.isNotEmpty ? provider.members[0].id : null;

    showGlassDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
                                    ),                     border: null,
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
                        BanglaLocalizations.of(context).addExtraFineBDT,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount (BDT)',
                                labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                                prefixIcon: Icon(Icons.monetization_on_outlined, color: Colors.grey[400], size: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.24)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF0D9488)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                            _buildMemberSelectorList(context, provider.members, selectedMemberId, (val) {
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
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (amountController.text.trim().isEmpty || selectedMemberId == null) return;
                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              provider.addFriedFineItem(selectedMemberId!, amount);
                              final member = provider.members.firstWhere((m) => m.id == selectedMemberId);

                              Navigator.pop(context);
                              GlassyNotification.show(context, message: 'Added BDT $amount fine to ${member.name}.');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(BanglaLocalizations.of(context).save, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showAddFineForMemberDialog(BuildContext context, MessProvider provider, Member member) {
    final amountController = TextEditingController();

    showGlassDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
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
                    'Add Fine for ${member.name}',
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount (BDT)',
                            labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                            prefixIcon: Icon(Icons.monetization_on_outlined, color: Colors.grey[400], size: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.24)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF0D9488)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.trim().isEmpty) return;
                          final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                          if (amount <= 0) return;

                          provider.addFriedFineItem(member.id, amount);

                          Navigator.pop(context);
                          GlassyNotification.show(context, message: 'Added BDT $amount fine to ${member.name}.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),                          child: Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  }

  void _showClearConfirmDialog(BuildContext context, MessProvider provider, Member member) {
    showGlassDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
                ),           elevation: null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
              width: 1.5,
            ),
          ),
          title:                      Text(
                        BanglaLocalizations.of(context).clearFines,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to clear all Fried & Fine amounts for ${member.name}?',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.clearMemberFriedFine(member.id);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Cleared all records for ${member.name}.');
              },
              child: Text(BanglaLocalizations.of(context).clearAll, style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeletePillConfirmDialog(BuildContext context, MessProvider provider, FriedFineItem item) {
    showGlassDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
                ),           elevation: null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
              width: 1.5,
            ),
          ),
          title: Text(
            'Delete Amount',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to delete this amount of BDT ${item.amount.toInt()}?',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteFriedFineItem(item.id);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Deleted amount BDT ${item.amount.toInt()}.');
              },
              child: Text(BanglaLocalizations.of(context).delete, style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

