import 'package:flutter/material.dart';

import '../l10n/bangla_localizations.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import '../widgets/glass_dialog.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final bn = BanglaLocalizations.of(context);
    final provider = Provider.of<MessProvider>(context);
    final payments = provider.payments;
    final totalPayments = provider.totalPayments;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent, // Blends into home_screen beige
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isDesktop ? 32.0 : 16.0,
              right: isDesktop ? 32.0 : 16.0,
              top: isDesktop ? 100.0 : 24.0,
              bottom: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desktop Header Title
                if (isDesktop) ...[
                  Text(
                    bn.messPayments,

                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bn.paymentsDesc,

                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 1. Header Pills Row - matching example layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left "Payments" pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.24), width: 1.0),
                      ),
                      child: Text(
                        bn.messPayments,

                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Right side desktop button + total pill
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDesktop) ...[
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
                                _showAddPaymentDialog(context, provider);
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      bn.addPayment,

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
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.24), width: 1.0),
                          ),
                          child: Text(
                            '${bn.total} = ${totalPayments.toInt()}',

                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Payments List
                Expanded(
                  child: payments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                bn.noPaymentsYet,

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
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            final payer = provider.members.firstWhere(
                              (m) => m.id == payment.memberId,
                              orElse: () => Member(
                                id: '',
                                name: 'Unknown',
                                email: '',
                                imageUrl: '',
                              ),
                            );
                            return _buildPaymentCard(context, provider, payment, payer);
                          },
                        ),
                ),
              ],
            ),
          ),

          // 3. Floating Action Button on Bottom Right - matching example layout
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
                        _showAddPaymentDialog(context, provider);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              bn.addPayment,

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
    );
  }

  Widget _buildPaymentCard(
      BuildContext context, MessProvider provider, Payment payment, Member payer) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: themeProvider.resolveColor(
          light: Colors.white,
          dark: const Color(0xFF0A0A0A),
            ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: payer.isActive ? 0.25 : 0.12),
          width: 2.0,
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
          // 1. Avatar (Mint/light-green background with first letter of payer's name)
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? const Color(0xFF065F46).withValues(alpha: 0.7) : const Color(0xFF86EFAC).withValues(alpha: 0.4),
            child: Text(
              payer.name.isNotEmpty ? payer.name.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF065F46),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Rounded Name Container (matching meals screen style)
          Container(
            width: 85,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.35)),
            ),
            child: Text(
              payer.name,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // 3. Payment Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // formatted like "22 jun"
                  DateFormat('d MMM').format(payment.date).toLowerCase(),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3. Amount Box (Green BDT text) & Edit/Delete - matching example layout
          Row(
            children: [
              // Amount Box
              Container(
                constraints: const BoxConstraints(minWidth: 42),
                height: 28,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.24)),
                ),
                child: Text(
                  '${payment.amount.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF0D9488), // Green text
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Edit button
              GestureDetector(
                onTap: () {
                  _showEditPaymentDialog(context, provider, payment);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.edit_rounded, color: isDark ? Colors.grey[300] : Colors.grey[600], size: 14),
                ),
              ),
              const SizedBox(width: 6),
              // Delete button
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmDialog(context, provider, payment);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelectorList(List<Member> members, String? selectedId, ValueChanged<String> onSelected) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 120, // Compact height
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

  void _showAddPaymentDialog(BuildContext context, MessProvider provider) {
    String? selectedMemberId = provider.members.isNotEmpty ? provider.members[0].id : null;
    final amountController = TextEditingController();

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
                        BanglaLocalizations.of(context).addPaymentRecord,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Member Selection Panel
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                BanglaLocalizations.of(context).selectMember2,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(provider.members, selectedMemberId, (val) {
                              setDialogState(() {
                                selectedMemberId = val;
                              });
                            }),
                            const SizedBox(height: 12),
                            // Amount Field
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Payment Amount (BDT)',
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
                            child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedMemberId == null || amountController.text.trim().isEmpty) return;

                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              final payment = Payment(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                memberId: selectedMemberId!,
                                amount: amount,
                                date: DateTime.now(),
                              );

                              provider.addPayment(payment);
                              Navigator.pop(context);
                              
                              final memberName = provider.members.firstWhere((m) => m.id == selectedMemberId).name;
                              GlassyNotification.show(context, message: 'Recorded BDT $amount payment for $memberName!');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(BanglaLocalizations.of(context).save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showEditPaymentDialog(BuildContext context, MessProvider provider, Payment payment) {
    String selectedMemberId = payment.memberId;
    final amountController = TextEditingController(text: payment.amount.toInt().toString());

    showGlassDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
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
                    ),                     border: Border.all(
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                      width: 1.5,
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
                        BanglaLocalizations.of(context).editPayment,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                BanglaLocalizations.of(context).selectMember2,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(provider.members, selectedMemberId, (val) {
                              setDialogState(() {
                                selectedMemberId = val;
                              });
                            }),
                            const SizedBox(height: 12),
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: BanglaLocalizations.of(context).paymentAmount,
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
                            child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (amountController.text.trim().isEmpty) return;

                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              provider.updatePayment(payment.id, selectedMemberId, amount);
                              Navigator.pop(context);
                              GlassyNotification.show(context, message: 'Updated payment details successfully!');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(BanglaLocalizations.of(context).save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showDeleteConfirmDialog(BuildContext context, MessProvider provider, Payment payment) {
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
            BanglaLocalizations.of(context).deletePayment,
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            BanglaLocalizations.of(context).paymentDeleteConfirm,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.deletePayment(payment.id);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Removed payment record.');
              },
              child: Text(BanglaLocalizations.of(context).delete, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

