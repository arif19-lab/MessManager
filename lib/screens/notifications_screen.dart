import 'dart:io';
import '../l10n/bangla_localizations.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool masterToggle = true;
  bool mealReminder = true;
  bool expenseTracking = true;
  bool paymentAlert = true;

  TimeOfDay mealTime = const TimeOfDay(hour: 20, minute: 0); // 8:00 PM
  TimeOfDay expenseTime = const TimeOfDay(hour: 21, minute: 0); // 9:00 PM
  TimeOfDay paymentTime = const TimeOfDay(hour: 10, minute: 0); // 10:00 AM

  final TextEditingController mealMsgCtrl = TextEditingController(text: "Don't forget to update your meal status");
  final TextEditingController expenseMsgCtrl = TextEditingController(text: "Have you added today's expenses?");
  final TextEditingController paymentMsgCtrl = TextEditingController(text: "Check for any pending payments.");

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await _initNotifications();
    await _loadSettings();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Could not set local timezone: $e');
    }
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const WindowsInitializationSettings initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Mess Manager',
      appUserModelId: 'com.imran.mess_manager',
      guid: 'a1234567-89ab-cdef-0123-456789abcdef',
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      windows: initializationSettingsWindows,
    );
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      masterToggle = prefs.getBool('notif_master') ?? true;
      mealReminder = prefs.getBool('notif_meal') ?? true;
      expenseTracking = prefs.getBool('notif_expense') ?? true;
      paymentAlert = prefs.getBool('notif_payment') ?? true;

      mealTime = _parseTime(prefs.getString('time_meal') ?? '20:00');
      expenseTime = _parseTime(prefs.getString('time_expense') ?? '21:00');
      paymentTime = _parseTime(prefs.getString('time_payment') ?? '10:00');

      mealMsgCtrl.text = prefs.getString('msg_meal') ?? "Don't forget to update your meal status";
      expenseMsgCtrl.text = prefs.getString('msg_expense') ?? "Have you added today's expenses?";
      paymentMsgCtrl.text = prefs.getString('msg_payment') ?? "Check for any pending payments.";
    });
    _scheduleAllNotifications();
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_master', masterToggle);
    await prefs.setBool('notif_meal', mealReminder);
    await prefs.setBool('notif_expense', expenseTracking);
    await prefs.setBool('notif_payment', paymentAlert);

    await prefs.setString('time_meal', _formatTimeOfDay(mealTime));
    await prefs.setString('time_expense', _formatTimeOfDay(expenseTime));
    await prefs.setString('time_payment', _formatTimeOfDay(paymentTime));

    await prefs.setString('msg_meal', mealMsgCtrl.text);
    await prefs.setString('msg_expense', expenseMsgCtrl.text);
    await prefs.setString('msg_payment', paymentMsgCtrl.text);

    _scheduleAllNotifications();
  }

  Future<void> _scheduleAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll(); // Clear existing

    if (!masterToggle) return;

    if (mealReminder) {
      _scheduleDailyNotification(0, 'Meal Reminder', mealMsgCtrl.text, mealTime);
    }
    if (expenseTracking) {
      _scheduleDailyNotification(1, 'Expense Tracking', expenseMsgCtrl.text, expenseTime);
    }
    if (paymentAlert) {
      _scheduleDailyNotification(2, 'Payment Alert', paymentMsgCtrl.text, paymentTime);
    }
  }

  Future<void> _scheduleDailyNotification(int id, String title, String body, TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'mess_manager_channel',
          'Mess Reminders',
          channelDescription: 'Daily reminders for mess manager',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
      _saveSettings();
    }
  }

  @override
  void dispose() {
    mealMsgCtrl.dispose();
    expenseMsgCtrl.dispose();
    paymentMsgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 850;
    final bn = BanglaLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: isDesktop ? 32 : 16,
          right: isDesktop ? 32 : 16,
          top: isDesktop ? 100 : 24,
          bottom: 24,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master Toggle Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bn.notificationsToggle,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bn.enableReceivingUpdates,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: masterToggle,
                    onChanged: (val) {
                      setState(() {
                        masterToggle = val;
                        mealReminder = val;
                        expenseTracking = val;
                        paymentAlert = val;
                      });
                      _saveSettings();
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF6EE7B7),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            
            Text(
              bn.reminders,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildReminderCard(
              title: bn.mealReminder,
              time: mealTime,
              isOn: mealReminder,
              msgController: mealMsgCtrl,
              onToggle: (val) {
                setState(() => mealReminder = val);
                _saveSettings();
              },
              onChangeTime: () => _pickTime(context, mealTime, (time) => setState(() => mealTime = time)),
              onMsgChanged: (val) => _saveSettings(),
            ),
            const SizedBox(height: 16),
            
            _buildReminderCard(
              title: bn.expenseTracking,
              time: expenseTime,
              isOn: expenseTracking,
              msgController: expenseMsgCtrl,
              onToggle: (val) {
                setState(() => expenseTracking = val);
                _saveSettings();
              },
              onChangeTime: () => _pickTime(context, expenseTime, (time) => setState(() => expenseTime = time)),
              onMsgChanged: (val) => _saveSettings(),
            ),
            const SizedBox(height: 16),

            _buildReminderCard(
              title: bn.paymentAlert,
              time: paymentTime,
              isOn: paymentAlert,
              msgController: paymentMsgCtrl,
              onToggle: (val) {
                setState(() => paymentAlert = val);
                _saveSettings();
              },
              onChangeTime: () => _pickTime(context, paymentTime, (time) => setState(() => paymentTime = time)),
              onMsgChanged: (val) => _saveSettings(),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required TimeOfDay time,
    required bool isOn,
    required TextEditingController msgController,
    required Function(bool) onToggle,
    required VoidCallback onChangeTime,
    required Function(String) onMsgChanged,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    final bn = BanglaLocalizations.of(context);
    // Format time for display (e.g., 8:00 pm)
    final timeStr = time.format(context).toLowerCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Switch(
                value: isOn,
                onChanged: masterToggle ? onToggle : null,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF047857), // Dark green toggle
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${bn.setFor} $timeStr',
            style: TextStyle(
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          InkWell(
            onTap: masterToggle ? onChangeTime : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey[600]! : const Color(0xFF94A3B8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${bn.changeTime}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.access_time, size: 14, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: msgController,
            enabled: masterToggle,
            onChanged: onMsgChanged,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: bn.customMessage,
              labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[500]!),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

