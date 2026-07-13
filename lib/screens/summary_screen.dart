import 'dart:io';
import 'dart:ui';
import '../providers/theme_provider.dart';
import '../widgets/glass_dialog.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:bangla_pdf_fixer/bangla_pdf_fixer.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import '../widgets/glassy_notification.dart';
import 'package:file_saver/file_saver.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  static final GlobalKey _reportKey = GlobalKey();

  void _showCloseCycleDialog(BuildContext context, MessProvider provider) {
    final textController = TextEditingController();
    
    // Suggest a default name based on cycle count
    textController.text = 'Cycle ${provider.billingCycles.length} (Closed)';

    showGlassDialog(
      context: context,
      builder: (BuildContext context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return AlertDialog(
            backgroundColor: themeProvider.resolveColor(
              light: Colors.white,
              dark: const Color(0xFF0A0A0A),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(                 color: Colors.transparent,
                width: 1,
              ),
            ),
          title: Text(
            'Close Active Meal?',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will lock all calculations for this meal permanently and start a fresh meal.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Meal Name',
                  hintText: 'e.g. June 1 - July 4',
                  labelStyle: const TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final cycleName = textController.text.trim();
                if (cycleName.isNotEmpty) {
                  provider.closeActiveCycle(cycleName);
                  Navigator.of(context).pop();
                  
                  // Show success snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal closed successfully! Started next meal.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Close Meal', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteCycleConfirmDialog(BuildContext context, MessProvider provider, BillingCycle cycle) {
    showGlassDialog(
      context: context,
      builder: (ctx) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return AlertDialog(
            backgroundColor: themeProvider.resolveColor(
              light: Colors.white,
              dark: const Color(0xFF0A0A0A),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(                 color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                width: 1.5,
              ),
            ),
          title: Row(
            children: [
              Image.asset(
                'assets/icons/remove.png',
                width: 22,
                height: 22,
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete ${cycle.name}?',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 280,
            child: Text(
              'Are you sure you want to permanently delete this billing cycle? All associated members, meals, expenses, and payments will be permanently deleted. This action cannot be undone!',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteBillingCycle(cycle.id);
                Navigator.of(ctx).pop(); // pop dialog
                Navigator.of(context).pop(); // pop cycles bottom sheet
                GlassyNotification.show(
                  context,
                  message: '${cycle.name} permanently deleted.',
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCyclesBottomSheet(BuildContext context, MessProvider provider, {Offset? anchorOffset}) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    Widget buildContent(BuildContext context, bool isDark, String currentSelectedId) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      
      return Container(
        width: isDesktop ? 400 : double.infinity,
        margin: EdgeInsets.zero, // Removed margin so it sits completely flush on mobile
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF06B6D4), // Cyan
              Color(0xFF3B82F6), // Blue
              Color(0xFF8B5CF6), // Purple
              Color(0xFFEC4899), // Pink
            ],
          ),
          borderRadius: isDesktop 
              ? BorderRadius.circular(28) 
              : const BorderRadius.vertical(top: Radius.circular(48)), // Increased top border radius significantly on mobile
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.4),
              offset: const Offset(0, 4),
              blurRadius: 24, // Stunning background glow
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop) ...[
              // Drag Handle for mobile bottom sheet
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Billing Cycles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select a cycle to view and edit its accounting reports',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Scrollable List of Cycles
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.billingCycles.length,
                  itemBuilder: (context, index) {
                    final cycle = provider.billingCycles[index];
                    final isSelected = currentSelectedId == cycle.id;
                    
                    // Dates display formatting
                    final range = provider.getCycleActiveDateRange(cycle.id);
                    final formatter = DateFormat('dd-MMM-yy');
                    final startStr = formatter.format(range['start']!);
                    final endStr = formatter.format(cycle.isActive ? DateTime.now() : range['end']!);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28), // slightly less rounded for smaller cards
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: InkWell(
                            onTap: () {
                              provider.setActiveCycle(cycle.id);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white.withValues(alpha: 0.15) 
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isSelected 
                                      ? Colors.white.withValues(alpha: 0.4) 
                                      : Colors.white.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Clear Glass State Icon Container
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent, // Completely transparent so icon pops
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Icon(
                                      cycle.isActive ? Icons.play_arrow_rounded : Icons.archive_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Cycle info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                cycle.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1),
                                                    )
                                                  ],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (cycle.isActive) ...[
                                              const SizedBox(width: 10),
                                              // Awesome glowing ACTIVE badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF10B981).withValues(alpha: 0.8),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.0),
                                                  boxShadow: [
                                                    BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.5), blurRadius: 6),
                                                  ],
                                                ),
                                                child: const Text(
                                                  'ACTIVE',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$startStr  →  $endStr',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.9),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Selected indicator check / Delete button
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      if (provider.billingCycles.length > 1)
                                        // Awesome glossy Delete Button
                                        IconButton(
                                          icon: Image.asset(
                                            'assets/icons/remove.png',
                                            width: 12,
                                            height: 12,
                                            color: Colors.white, // Changed to pure white for maximum clarity
                                          ),
                                          onPressed: () {
                                            _showDeleteCycleConfirmDialog(context, provider, cycle);
                                          },
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.35), // slightly more opaque red glass
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(28, 28),
                                            maximumSize: const Size(28, 28),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.8), width: 1.5), // Crisp red border
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ), // Close ConstrainedBox
            ), // Close Flexible
          ],
        ),
      );
    }

    if (isDesktop && anchorOffset != null) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Cycles',
        barrierColor: Colors.black.withValues(alpha: 0.6), // Reduced dim background opacity
        pageBuilder: (context, anim1, anim2) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final currentSelectedId = provider.activeCycleId;
          
          return Stack(
            children: [
              Positioned(
                top: 102,
                right: 16, // Same position as the Settings panel
                child: Material(
                  color: Colors.transparent,
                  child: buildContent(context, isDark, currentSelectedId),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.6), // Reduced dim background opacity
        builder: (BuildContext context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final currentSelectedId = provider.activeCycleId;
          return buildContent(context, isDark, currentSelectedId);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    
    // Derived metrics for summary
    double mealRate = provider.mealRate;
    double totalMeals = provider.totalMeals;
    double totalPayments = provider.totalPayments;
    double totalCost = provider.totalExpenses;
    
    // Simple calculation for Receivables (what people owe the mess) and Payables (what mess owes people or shop)
    double receivables = 0.0;
    double payables = 0.0;
    
    for (var m in provider.members) {
      double bal = provider.getMemberBalance(m);
      if (bal > 0) {
        payables += bal; // Mess owes the member (they paid extra)
      } else if (bal < 0) {
        receivables += bal.abs(); // Member owes the mess
      }
    }
    
    // Add shop due to payables
    payables += provider.shopDue;

    final currentCycle = provider.billingCycles.firstWhere(
      (c) => c.id == provider.activeCycleId,
      orElse: () => BillingCycle(id: 'cycle_1', name: 'Meal 1', startDate: DateTime.now(), isActive: true),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Align(
          alignment: Alignment.topLeft,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = isDesktop && constraints.maxWidth > 1200 ? 1200.0 : double.infinity;
              return RepaintBoundary(
                key: _reportKey,
                child: Container(
                  width: contentWidth,
                  color: Colors.transparent,
                padding: EdgeInsets.only(
                  left: isDesktop ? 32 : 16,
                  right: isDesktop ? 32 : 16,
                  top: isDesktop ? 100 : 24,
                  bottom: isDesktop ? 24 : 170, // Clear the 90px mobile navbar with extra breathing room since extendBody is true
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top action buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _showCloseCycleDialog(context, provider),
                            borderRadius: BorderRadius.circular(24),
                            child: _buildActionButton('Close Meal', const Color(0xFFEF4444), Colors.white),
                          ),
                          const SizedBox(width: 12),
                           InkWell(
                            onTap: () => _generateAndPrintPDF(context, provider, currentCycle.name, mealRate),
                            borderRadius: BorderRadius.circular(24),
                            child: _buildActionButton('PDF', isDark ? Colors.white24 : Colors.black, Colors.white, icon: Icons.download),
                          ),
                          const SizedBox(width: 12),
                          Builder(
                            builder: (btnContext) => InkWell(
                              onTap: () {
                                final RenderBox button = btnContext.findRenderObject() as RenderBox;
                                final Offset offset = button.localToGlobal(Offset(0, button.size.height + 8));
                                _showCyclesBottomSheet(context, provider, anchorOffset: offset);
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: themeProvider.resolveColor(
                                    light: Colors.white,
                                    dark: const Color(0xFF0A0A0A),
                                                          ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF047857),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentCycle.name,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.teal[300] : const Color(0xFF047857), size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24.0 : 12.0),

                     // 6-Card Grid (Responsive: auto-width on desktop, 2-columns on mobile)
                     LayoutBuilder(
                       builder: (context, constraints) {
                         final isDesktop = constraints.maxWidth > 600;
                         final double spacing = isDesktop ? 16.0 : 10.0;
                         final double? itemWidth = isDesktop 
                             ? null 
                             : (constraints.maxWidth - spacing) / 2;

                         Widget buildCard(String title, String value, Color color) {
                           final card = _buildStatCard(context, title, value, color);
                           if (itemWidth != null) {
                             return SizedBox(
                               width: itemWidth,
                               child: card,
                             );
                           }
                           return card;
                         }

                         return Wrap(
                           spacing: spacing,
                           runSpacing: spacing,
                           children: [
                             buildCard('Current Meal Rate', '${mealRate.toStringAsFixed(2)} ৳', const Color(0xFF3B82F6)),
                             buildCard('Total Meals', totalMeals.toStringAsFixed(0), const Color(0xFF10B981)),
                             buildCard('Total Payments', '${totalPayments.toStringAsFixed(0)} ৳', const Color(0xFF8B5CF6)),
                             buildCard('Total Cost', '${totalCost.toStringAsFixed(0)} ৳', const Color(0xFFF97316)),
                             buildCard('Receivables', '${receivables.toStringAsFixed(0)} ৳', const Color(0xFF10B981)),
                             buildCard('Payables', '${payables.toStringAsFixed(0)} ৳', const Color(0xFFEF4444)),
                           ],
                         );
                       },
                     ),
                    SizedBox(height: isDesktop ? 24.0 : 12.0),

                    // Data Table Section
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.resolveColor(
                          light: Colors.white,
                          dark: const Color(0xFF0A0A0A),
                                      ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
                              child: Text(
                                'Monthly Summary Sheet (By Mess Manager)',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final sortedMembers = provider.members.where((m) => m.isActive).toList();
                              sortedMembers.sort((a, b) {
                                double aDue = (a.totalMeals * mealRate) - a.payments;
                                double bDue = (b.totalMeals * mealRate) - b.payments;
                                int aGroup = aDue < 0 ? 1 : (aDue == 0 ? 2 : 3);
                                int bGroup = bDue < 0 ? 1 : (bDue == 0 ? 2 : 3);
                                if (aGroup != bGroup) {
                                  return aGroup.compareTo(bGroup);
                                }
                                if (aGroup == 1) {
                                  return bDue.abs().compareTo(aDue.abs());
                                } else if (aGroup == 3) {
                                  return bDue.compareTo(aDue);
                                }
                                return 0;
                              });

                              if (constraints.maxWidth <= 600) {
                                // Mobile Table: Fits exactly on one screen without scrolling
                                Widget buildMobileTableHeaderCell(String text) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                                    child: Center(
                                      child: Text(
                                        text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                Widget buildMobileTableCell(String text, {bool isBold = false, TextAlign align = TextAlign.center}) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                                    child: align == TextAlign.left
                                        ? Text(
                                            text,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                                              fontSize: 10.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Text(
                                            text,
                                            style: TextStyle(
                                              color: isDark ? Colors.white : Colors.black87,
                                              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                                              fontSize: 10.5,
                                            ),
                                            textAlign: align,
                                          ),
                                  );
                                }

                                return Table(
                                  border: TableBorder.all(
                                    color: isDark ? Colors.white24 : Colors.black87,
                                    width: 1.5,
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2.3), // Member Name
                                    1: FlexColumnWidth(1.1), // Meals
                                    2: FlexColumnWidth(1.2), // Bill
                                    3: FlexColumnWidth(1.2), // Paid
                                    4: FlexColumnWidth(2.2), // Balance
                                  },
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(color: Color(0xFF166534)),
                                      children: [
                                        buildMobileTableHeaderCell('Member'),
                                        buildMobileTableHeaderCell('Meals'),
                                        buildMobileTableHeaderCell('Bill'),
                                        buildMobileTableHeaderCell('Paid'),
                                        buildMobileTableHeaderCell('Balance'),
                                      ],
                                    ),
                                    ...sortedMembers.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final member = entry.value;
                                      double memBill = member.totalMeals * mealRate;
                                      double memPaid = member.payments;
                                      double memDue = memBill - memPaid;

                                      final isEven = index % 2 == 0;
                                      final rowBgColor = isEven 
                                          ? themeProvider.resolveColor(
                                              light: const Color(0xFFF8FAFC),
                                              dark: const Color(0xFF1E293B),
                                            )
                                          : themeProvider.resolveColor(
                                              light: Colors.white,
                                              dark: const Color(0xFF0A0A0A),
                                                                              );

                                      Widget balanceWidget;
                                      if (memDue > 0) {
                                        balanceWidget = Text(
                                          '${memDue.toStringAsFixed(0)} ৳ (Pay)',
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      } else if (memDue < 0) {
                                        balanceWidget = Text(
                                          '${memDue.abs().toStringAsFixed(0)} ৳ (Due)',
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      } else {
                                        balanceWidget = Text(
                                          'Settled',
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        );
                                      }

                                      return TableRow(
                                        decoration: BoxDecoration(color: rowBgColor),
                                        children: [
                                          buildMobileTableCell(member.name, isBold: true, align: TextAlign.left),
                                          buildMobileTableCell(member.totalMeals.toStringAsFixed(0)),
                                          buildMobileTableCell(memBill.toStringAsFixed(0)),
                                          buildMobileTableCell(member.payments.toStringAsFixed(0)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                                            child: Center(child: balanceWidget),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFF166534)),
                                    dividerThickness: 1.5,
                                    border: TableBorder.all(color: isDark ? Colors.white24 : Colors.black87, width: 1.5),
                                    columnSpacing: constraints.maxWidth > 600 ? (constraints.maxWidth / 7) : 20,
                                    columns: const [
                                      DataColumn(label: Text('Member Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Total Meals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Bill (Tk)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Paid (Tk)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    ],
                                    rows: sortedMembers.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final member = entry.value;
                                      double memBill = member.totalMeals * mealRate;
                                      double memPaid = member.payments;
                                      double memDue = memBill - memPaid;

                                      final isEven = index % 2 == 0;
                                      final rowBgColor = isEven 
                                          ? themeProvider.resolveColor(
                                              light: const Color(0xFFF8FAFC),
                                              dark: const Color(0xFF1E293B),
                                            )
                                          : themeProvider.resolveColor(
                                              light: Colors.white,
                                              dark: const Color(0xFF0A0A0A),
                                                                              );

                                      Widget balanceWidget;
                                      if (memDue > 0) {
                                        balanceWidget = Text(
                                          '${memDue.toStringAsFixed(0)} Tk (Pay)',
                                          style: const TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      } else if (memDue < 0) {
                                        balanceWidget = Text(
                                          '${memDue.abs().toStringAsFixed(0)} Tk (Due)',
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      } else {
                                        balanceWidget = Text(
                                          'Settled',
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                                            fontSize: 12,
                                          ),
                                        );
                                      }

                                      return DataRow(
                                        color: WidgetStateProperty.all(rowBgColor),
                                        cells: [
                                          DataCell(Text(member.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500))),
                                          DataCell(Text(member.totalMeals.toStringAsFixed(0), style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                                          DataCell(Text(memBill.toStringAsFixed(0), style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                                          DataCell(Text(memPaid.toStringAsFixed(0), style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
                                          DataCell(balanceWidget),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor, {IconData? icon, bool isOutlined = false}) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: isOutlined ? Border.all(color: Colors.grey[400]!) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color valueColor, {Color? bgColor}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = valueColor;
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.resolveColor(
          light: Colors.white,
          dark: const Color(0xFF0A0A0A),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor, 
          width: 1.5
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0, right: 36.0, bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            fontSize: 9.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: -1.5,
              right: -1.5,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: accentColor, width: 1.5),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndPrintPDF(BuildContext context, MessProvider provider, String cycleName, double mealRate) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Generating high-quality PDF report...'),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }

      ByteData fontByteData;
      try {
        fontByteData = await rootBundle.load('packages/bangla_pdf_fixer/lib/fonts/Default/kalpurush.ttf');
      } catch (_) {
        fontByteData = await rootBundle.load('packages/bangla_pdf_fixer/fonts/Default/kalpurush.ttf');
      }
      final regularFont = pw.Font.ttf(fontByteData);
      final boldFont = pw.Font.ttf(fontByteData);

      bool hasBangla(String text) {
        return RegExp(r'[\u0980-\u09FF]').hasMatch(text);
      }

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
      );
      final currentCycle = provider.billingCycles.firstWhere(
        (c) => c.id == provider.activeCycleId,
        orElse: () => BillingCycle(id: provider.activeCycleId, name: 'Meal', startDate: DateTime.now(), isActive: true),
      );
      final activeRange = provider.getCycleActiveDateRange(provider.activeCycleId);
      final formatter = DateFormat('dd-MMM-yy');
      final activeStartStr = formatter.format(activeRange['start']!);
      final activeEndStr = formatter.format(currentCycle.isActive ? DateTime.now() : activeRange['end']!);
      final activeDateRangeStr = '$activeStartStr --- $activeEndStr';

      final double totalMeals = provider.totalMeals;
      final double totalPayments = provider.totalPayments;
      final double totalCost = provider.totalExpenses;
      
      double receivables = 0.0;
      double payables = 0.0;
      for (var m in provider.members) {
        double bal = provider.getMemberBalance(m);
        if (bal > 0) {
          payables += bal;
        } else if (bal < 0) {
          receivables += bal.abs();
        }
      }
      payables += provider.shopDue;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (pw.Context context) {
            int rowIndex = 0;
            final sortedMembers = provider.members.where((m) => m.isActive).toList();
            sortedMembers.sort((a, b) {
              double aDue = (a.totalMeals * mealRate) - a.payments;
              double bDue = (b.totalMeals * mealRate) - b.payments;
              int aGroup = aDue < 0 ? 1 : (aDue == 0 ? 2 : 3);
              int bGroup = bDue < 0 ? 1 : (bDue == 0 ? 2 : 3);
              if (aGroup != bGroup) {
                return aGroup.compareTo(bGroup);
              }
              if (aGroup == 1) {
                return bDue.abs().compareTo(aDue.abs());
              } else if (aGroup == 3) {
                return bDue.compareTo(aDue);
              }
              return 0;
            });
            return [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.teal900, PdfColors.teal700],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Left info: App Title & Subtitles
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        hasBangla(cycleName)
                            ? pw.Text(
                                'MESS MANAGER - ${cycleName.toUpperCase().fix}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.teal100,
                                  letterSpacing: 1.5,
                                  font: regularFont,
                                ),
                              )
                            : pw.Text(
                                'MESS MANAGER - ${cycleName.toUpperCase()}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.teal100,
                                  letterSpacing: 1.5,
                                ),
                              ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'MONTHLY REPORT SHEET',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        // Date label
                        pw.Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                          style: const pw.TextStyle(
                            fontSize: 9.5,
                            color: PdfColors.teal100,
                          ),
                        ),
                      ],
                    ),
                    // Right info: Cycle Date Range Card
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.teal900,
                        border: pw.Border.all(color: PdfColors.teal300, width: 1.2),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text(
                            'CYCLE DURATION',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            activeDateRangeStr,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.teal200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Section 1: Overview Title
              pw.Text(
                'CYCLE OVERVIEW METRICS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
              pw.SizedBox(height: 10),

              // 6 Stats Cards (arranged in 2 rows of 3 columns)
              pw.Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPdfStatCard('CURRENT MEAL RATE', '${mealRate.toStringAsFixed(2)} Tk', PdfColors.blue800),
                  _buildPdfStatCard('TOTAL MEALS', totalMeals.toStringAsFixed(0), PdfColors.green800),
                  _buildPdfStatCard('TOTAL PAYMENTS', '${totalPayments.toStringAsFixed(0)} Tk', PdfColors.purple800),
                  _buildPdfStatCard('TOTAL COST', '${totalCost.toStringAsFixed(0)} Tk', PdfColors.orange800),
                  _buildPdfStatCard('RECEIVABLES', '${receivables.toStringAsFixed(0)} Tk', PdfColors.teal800),
                  _buildPdfStatCard('PAYABLES', '${payables.toStringAsFixed(0)} Tk', PdfColors.red800),
                ],
              ),
              pw.SizedBox(height: 24),

              // Section 2: Detailed Sheet Title
              pw.Text(
                'MONTHLY SUMMARY SHEET (BY MESS MANAGER)',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal800,
                ),
              ),
              pw.SizedBox(height: 10),

              // Table of Members
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1.5),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(2.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.teal800,
                    ),
                    children: [
                      _buildPdfHeaderCell('Member Name'),
                      _buildPdfHeaderCell('Total Meals', align: pw.Alignment.center),
                      _buildPdfHeaderCell('Bill (Tk)', align: pw.Alignment.center),
                      _buildPdfHeaderCell('Paid (Tk)', align: pw.Alignment.center),
                      _buildPdfHeaderCell('Balance', align: pw.Alignment.center),
                    ],
                  ),
                  ...sortedMembers.map((member) {
                    double memBill = member.totalMeals * mealRate;
                    double memPaid = member.payments;
                    double memDue = memBill - memPaid;
                    
                    pw.Widget balanceWidget;
                    if (memDue > 0) {
                      balanceWidget = pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          '${memDue.toStringAsFixed(0)} Tk (Pay)'.fix,
                          style: pw.TextStyle(
                            color: PdfColors.red800,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8.5,
                          ),
                        ),
                      );
                    } else if (memDue < 0) {
                      balanceWidget = pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          '${memDue.abs().toStringAsFixed(0)} Tk (Due)'.fix,
                          style: pw.TextStyle(
                            color: PdfColors.green800,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8.5,
                          ),
                        ),
                      );
                    } else {
                      balanceWidget = pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(
                          'Settled'.fix,
                          style: const pw.TextStyle(
                            color: PdfColors.grey600,
                            fontSize: 8.5,
                          ),
                        ),
                      );
                    }
                    
                    final isEven = rowIndex++ % 2 == 0;
                    final rowBg = isEven ? PdfColors.white : PdfColors.grey100;
                    
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: rowBg,
                      ),
                      children: [
                        _buildPdfCell(
                          hasBangla(member.name) ? member.name.fix : member.name,
                          font: hasBangla(member.name) ? regularFont : null,
                        ),
                        _buildPdfCell(member.totalMeals.toStringAsFixed(0), align: pw.Alignment.center),
                        _buildPdfCell(memBill.toStringAsFixed(0), align: pw.Alignment.center),
                        _buildPdfCell(memPaid.toStringAsFixed(0), align: pw.Alignment.center),
                        _buildPdfCellWidget(balanceWidget),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      final timestamp = DateFormat('dd_MMM_yyyy_hh_mm_a').format(DateTime.now());
      final fileName = 'Mess_Report_${cycleName.replaceAll(" ", "_")}_$timestamp';

      // Use the robust printing package to share/save the PDF safely across all platforms
      await Printing.sharePdf(
        bytes: bytes,
        filename: '$fileName.pdf',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      // Fallback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfStatCard(String title, String value, PdfColor accentColor) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: accentColor, width: 1.2),
      ),
      child: pw.Stack(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10, top: 8, right: 28, bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Container(
                      width: 10,
                      height: 10,
                      decoration: pw.BoxDecoration(
                        color: accentColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                    ),
                    pw.SizedBox(width: 5),
                    pw.Text(
                      title.toUpperCase().fix,
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  value.fix,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          pw.Positioned(
            bottom: 0,
            right: 0,
            child: pw.Container(
              width: 18,
              height: 18,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: accentColor, width: 1.2),
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(6),
                  bottomRight: pw.Radius.circular(8.8),
                ),
              ),
              alignment: pw.Alignment.center,
              child: pw.Container(
                width: 4,
                height: 4,
                decoration: pw.BoxDecoration(
                  color: accentColor,
                  shape: pw.BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  pw.Widget _buildPdfHeaderCell(String text, {pw.AlignmentGeometry align = pw.Alignment.centerLeft, pw.Font? font}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text.fix,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          font: font,
        ),
      ),
    );
  }

  pw.Widget _buildPdfCell(String text, {pw.AlignmentGeometry align = pw.Alignment.centerLeft, pw.Font? font}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text.fix,
        style: pw.TextStyle(
          color: PdfColors.grey900,
          fontSize: 8.5,
          font: font,
        ),
      ),
    );
  }

  pw.Widget _buildPdfCellWidget(pw.Widget child, {pw.AlignmentGeometry? align}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: child,
    );
  }
}

