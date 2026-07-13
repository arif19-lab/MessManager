import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import '../providers/mess_provider.dart';
import '../models/mess_data.dart';
import '../widgets/glass_dialog.dart';
import 'package:mess_manager/widgets/glassy_notification.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MessProvider>(context);
    final allMembers = provider.members;
    final members = allMembers;
    final totalMembersCount = allMembers.length;

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
                // Title & Subtitle for Desktop
                if (isDesktop) ...[
                  Text(
                    'Members Directory',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage mess members, room numbers, and contact details',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 1. Header Pill Row - matching example layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left "Members List" pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.24), width: 1.0),
                      ),
                      child: Text(
                        'Members List',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Right "Total = X" pill
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
                                _showAddMemberDialog(context, provider);
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_add_alt_1_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add Member',
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
                            'Total = $totalMembersCount',
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

                // 2. Members List
                Expanded(
                  child: members.isEmpty
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
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            return _buildMemberCard(context, provider, member);
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
                        _showAddMemberDialog(context, provider);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Add Member',
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

  Widget _buildMemberCard(BuildContext context, MessProvider provider, Member member) {
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: member.isActive ? 0.25 : 0.12),
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
          // 1. Avatar (Mint/light-green background with first letter of name)
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
          const SizedBox(width: 12),

          // 2. Info details (Name, Room/Location pin, Phone icon)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Location/Room Pin
                    Icon(Icons.location_on_outlined, color: Colors.grey[500], size: 12),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        member.roomNumber.isNotEmpty ? member.roomNumber : 'N/A',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Phone Number
                    Icon(Icons.phone_outlined, color: const Color(0xFF0D9488), size: 12),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        member.phone.isNotEmpty ? member.phone : 'N/A',
                        style: const TextStyle(
                          color: Color(0xFF0D9488),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Edit & Delete action buttons - matching example layout
          Row(
            children: [
              // Edit button
              GestureDetector(
                onTap: () {
                  _showEditMemberDialog(context, provider, member);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.edit_rounded, color: Colors.grey[600], size: 14),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmDialog(context, provider, member);
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

  void _showAddMemberDialog(BuildContext context, MessProvider provider) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final roomController = TextEditingController();
    final emailController = TextEditingController();

    showGlassDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
          ),           elevation: null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Add New Member',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(nameController, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _buildDialogField(emailController, 'Email Address', Icons.mail_outline),
                const SizedBox(height: 12),
                _buildDialogField(phoneController, 'Phone Number', Icons.phone_android_outlined),
                const SizedBox(height: 12),
                _buildDialogField(roomController, 'Room / Seat Number', Icons.room_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                
                final newMember = Member(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  email: emailController.text.trim().isNotEmpty 
                      ? emailController.text.trim() 
                      : '${nameController.text.trim().toLowerCase().replaceAll(' ', '')}@gmail.com',
                  imageUrl: '',
                  phone: phoneController.text.trim(),
                  roomNumber: roomController.text.trim(),
                  isActive: true,
                  isActiveToday: false,
                );
                
                provider.addMember(newMember);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Added member ${newMember.name} successfully!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditMemberDialog(BuildContext context, MessProvider provider, Member member) {
    final nameController = TextEditingController(text: member.name);
    final phoneController = TextEditingController(text: member.phone);
    final roomController = TextEditingController(text: member.roomNumber);

    showGlassDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
          ),           elevation: null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Edit Member Details',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(nameController, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _buildDialogField(phoneController, 'Phone Number', Icons.phone_android_outlined),
                const SizedBox(height: 12),
                _buildDialogField(roomController, 'Room / Seat Number', Icons.room_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                
                provider.updateMemberDetails(
                  member.id,
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  roomController.text.trim(),
                );
                
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Updated member details successfully!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, MessProvider provider, Member member) {
    showGlassDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        bool isDark = themeProvider.isDarkMode;
        return AlertDialog(
          backgroundColor: themeProvider.resolveColor(
            light: Colors.white,
            dark: const Color(0xFF0A0A0A),
          ),           elevation: null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Member',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'Are you sure you want to delete ${member.name} from the mess directory?',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                provider.deleteMember(member.id);
                Navigator.pop(context);
                GlassyNotification.show(context, message: 'Removed ${member.name} from directory.');
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
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

