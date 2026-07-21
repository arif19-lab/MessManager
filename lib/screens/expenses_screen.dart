import 'package:flutter/material.dart';

import '../l10n/bangla_localizations.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';
import '../widgets/glass_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _showShopDue = false;

  @override
  Widget build(BuildContext context) {
    final bn = BanglaLocalizations.of(context);
    final provider = Provider.of<MessProvider>(context);
    
    // Calculations
    final totalExpenses = provider.totalExpenses;
    final totalShopDue = provider.shopDue;

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
                    _showShopDue ? bn.shopDueRecords : bn.messExpenses,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _showShopDue
                        ? bn.shopDueDesc
                        : bn.expensesDesc,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 1. Header Pills Row - matching both screenshots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left dynamic button
                    _showShopDue
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                _showShopDue = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white12 : Colors.grey[200], // Back Expenses style
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.24), width: 1.0),
                              ),
                              child: Text(
                                bn.backExpenses,
                                style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          )
                        : InkWell(
                            onTap: () {
                              setState(() {
                                _showShopDue = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.transparent, // Add Shop Due - matches Add Expense green style
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                bn.addShopDue,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            )
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
                                if (_showShopDue) {
                                  _showAddShopDueDialog(context, provider);
                                } else {
                                  _showAddExpenseDialog(context, provider);
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showShopDue ? Icons.add_card_rounded : Icons.add_shopping_cart_rounded,
                                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _showShopDue ? bn.addAmount : bn.addExpense,
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
                            '${bn.total} = ${_showShopDue ? totalShopDue.toInt() : totalExpenses.toInt()}',
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

                // 2. Data List
                Expanded(
                  child: _showShopDue
                      ? _buildShopDueList(context, provider)
                      : _buildExpensesList(context, provider),
                ),
              ],
            ),
          ),

          // 3. Floating Action Button - matching screenshots
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
                        if (_showShopDue) {
                          _showAddShopDueDialog(context, provider);
                        } else {
                          _showAddExpenseDialog(context, provider);
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showShopDue ? Icons.add_card_rounded : Icons.add_shopping_cart_rounded,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _showShopDue ? bn.addAmount : bn.addExpense,
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

  // --- Expenses List View ---
  Widget _buildExpensesList(BuildContext context, MessProvider provider) {
    final expenses = provider.expenses;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              BanglaLocalizations.of(context).noExpensesYet,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(bottom: isDesktop ? 24 : (100 + bottomPadding)),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(context, provider, expense);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, MessProvider provider, Expense expense) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final buyer = provider.members.firstWhere(
      (m) => m.id == expense.buyerId,
      orElse: () => Member(id: '', name: 'Unknown', email: '', imageUrl: '', roomNumber: '', phone: ''),
    );

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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: buyer.isActive ? 0.25 : 0.12),
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
          // 1. Avatar (Mint/light-green background with first letter of buyer's name)
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? const Color(0xFF065F46).withValues(alpha: 0.7) : const Color(0xFF86EFAC).withValues(alpha: 0.4),
            child: Text(
              buyer.name.isNotEmpty ? buyer.name.substring(0, 1).toUpperCase() : '?',
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
              buyer.name,
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

          // 3. Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd MMM yyyy').format(expense.date),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3. Amount Box (Red) & Edit/Delete
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
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.24)),
                ),
                child: Text(
                  '${expense.amount.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFFEF4444), // Red text
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Edit button
              GestureDetector(
                onTap: () {
                  _showEditExpenseDialog(context, provider, expense);
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
                  _showDeleteExpenseConfirmDialog(context, provider, expense);
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

  // --- Shop Due List View ---
  Widget _buildShopDueList(BuildContext context, MessProvider provider) {
    final items = provider.shopDueItems;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              BanglaLocalizations.of(context).noShopDuesYet,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(bottom: isDesktop ? 24 : (100 + bottomPadding)),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildShopDueCard(context, provider, item);
      },
    );
  }

  Widget _buildShopDueCard(BuildContext context, MessProvider provider, ShopDueItem item) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final buyer = provider.members.firstWhere(
      (m) => m.id == item.buyerId,
      orElse: () => Member(id: '', name: 'Unknown', email: '', imageUrl: '', roomNumber: '', phone: ''),
    );

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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: buyer.isActive ? 0.25 : 0.12),
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
          // 1. Avatar (Mint/light-green background with first letter of buyer's name)
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? const Color(0xFF065F46).withValues(alpha: 0.7) : const Color(0xFF86EFAC).withValues(alpha: 0.4),
            child: Text(
              buyer.name.isNotEmpty ? buyer.name.substring(0, 1).toUpperCase() : '?',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF065F46),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 2. Rounded Name Container (matching meals/expenses style)
          Container(
            width: 85,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.35)),
            ),
            child: Text(
              buyer.name,
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

          // 3. Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd MMM yyyy').format(item.date),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3. Amount Box (Green) & Edit/Delete
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
                  '${item.amount.toInt()}',
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
                  _showEditShopDueDialog(context, provider, item);
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
                  _showDeleteShopDueConfirmDialog(context, provider, item);
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

  // --- Dialog Helpers ---
  Widget _buildMemberSelectorList(List<Member> members, String? selectedId, ValueChanged<String> onSelected) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 120, // Compact height
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC),
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

  void _showAddExpenseDialog(BuildContext context, MessProvider provider) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedBuyerId = provider.members.isNotEmpty ? provider.members[0].id : null;

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
                        '${BanglaLocalizations.of(context).addExpenseItem}',
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogField(titleController, BanglaLocalizations.of(context).expenseTitle, Icons.shopping_bag_outlined),
                            const SizedBox(height: 12),
                            _buildDialogField(amountController, BanglaLocalizations.of(context).amountBDT, Icons.monetization_on_outlined, isNumeric: true),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Buyer',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(provider.members, selectedBuyerId, (val) {
                              setDialogState(() {
                                selectedBuyerId = val;
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
                              if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty || selectedBuyerId == null) return;
                              
                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              final newExpense = Expense(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleController.text.trim(),
                                amount: amount,
                                date: DateTime.now(),
                                buyerId: selectedBuyerId!,
                              );

                              provider.addExpense(newExpense);
                              Navigator.pop(context);
                              GlassyNotification.show(context, message: 'Added expense "${newExpense.title}" successfully!');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showEditExpenseDialog(BuildContext context, MessProvider provider, Expense expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toInt().toString());
    String selectedBuyerId = expense.buyerId;

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
                        '${BanglaLocalizations.of(context).editExpense}',
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogField(titleController, BanglaLocalizations.of(context).expenseTitle, Icons.shopping_bag_outlined),
                            const SizedBox(height: 12),
                            _buildDialogField(amountController, BanglaLocalizations.of(context).amountBDT, Icons.monetization_on_outlined, isNumeric: true),
                            const SizedBox(height: 16),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Buyer',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(provider.members, selectedBuyerId, (val) {
                              setDialogState(() {
                                selectedBuyerId = val;
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
                            child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty) return;

                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              provider.updateExpense(
                                expense.id,
                                titleController.text.trim(),
                                amount,
                                selectedBuyerId,
                              );

                              Navigator.pop(context);
                              GlassyNotification.show(context, message: 'Updated expense details successfully!');
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

  void _showDeleteExpenseConfirmDialog(BuildContext context, MessProvider provider, Expense expense) {
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
          title: Text(                '${BanglaLocalizations.of(context).deleteExpense}',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to delete expense "${expense.title}"?',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteExpense(expense.id);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Removed expense "${expense.title}".');
              },
              child: Text(BanglaLocalizations.of(context).delete, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddShopDueDialog(BuildContext context, MessProvider provider) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedBuyerId = provider.members.isNotEmpty ? provider.members[0].id : null;

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
                        '${BanglaLocalizations.of(context).addShopDueRecord}',
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogField(titleController, BanglaLocalizations.of(context).dueItemTitle, Icons.payment_outlined),
                            const SizedBox(height: 12),
                            _buildDialogField(amountController, BanglaLocalizations.of(context).amountBDT, Icons.monetization_on_outlined, isNumeric: true),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(                                 '${BanglaLocalizations.of(context).selectMember2}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(provider.members, selectedBuyerId, (val) {
                              setDialogState(() {
                                selectedBuyerId = val;
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
                            child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty || selectedBuyerId == null) return;

                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              final newDue = ShopDueItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleController.text.trim(),
                                amount: amount,
                                date: DateTime.now(),
                                buyerId: selectedBuyerId!,
                              );

                              provider.addShopDueItem(newDue);
                              Navigator.pop(context);
                              GlassyNotification.show(context, message: 'Added shop due "${newDue.title}" successfully!');
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

  void _showEditShopDueDialog(BuildContext context, MessProvider provider, ShopDueItem item) {
    final titleController = TextEditingController(text: item.title);
    final amountController = TextEditingController(text: item.amount.toInt().toString());
    String selectedBuyerId = item.buyerId;

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
                        '${BanglaLocalizations.of(context).editShopDue}',
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDialogField(titleController, BanglaLocalizations.of(context).dueItemTitle, Icons.payment_outlined),
                            const SizedBox(height: 12),
                            _buildDialogField(amountController, BanglaLocalizations.of(context).amountBDT, Icons.monetization_on_outlined, isNumeric: true),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(                                 '${BanglaLocalizations.of(context).selectMember2}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildMemberSelectorList(provider.members, selectedBuyerId, (val) {
                              setDialogState(() {
                                selectedBuyerId = val;
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
                            child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty) return;

                              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (amount <= 0) return;

                              provider.updateShopDueItem(
                                item.id,
                                titleController.text.trim(),
                                amount,
                                selectedBuyerId,
                              );

                              Navigator.pop(context);
                              GlassyNotification.show(context, message: 'Updated shop due details successfully!');
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

  void _showDeleteShopDueConfirmDialog(BuildContext context, MessProvider provider, ShopDueItem item) {
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
          title: Text(                '${BanglaLocalizations.of(context).deleteShopDue}',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to delete shop due "${item.title}"?',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(BanglaLocalizations.of(context).cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteShopDueItem(item.id);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Removed shop due "${item.title}".');
              },
              child: Text(BanglaLocalizations.of(context).delete, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),
        filled: isDark,
        fillColor: isDark ? Colors.black : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.withValues(alpha: 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D9488)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}

