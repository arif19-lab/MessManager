import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mess_data.dart';
import '../services/firebase_service.dart';
import '../services/auth_mode_service.dart';
import '../database/local_database.dart';

class MessProvider extends ChangeNotifier {
  final List<Member> _members = [];
  final List<Expense> _expenses = [];
  final List<Payment> _payments = [];
  final List<ShopDueItem> _shopDueItems = [];
  final List<FriedFineItem> _friedFineItems = [];
  final List<GuestMeal> _guestMealRecords = [];
  final List<DailyMeal> _dailyMeals = [];
  final List<BillingCycle> _billingCycles = [];

  String _activeCycleId = 'cycle_1';

  String? _customAvatarPath;
  String? get customAvatarPath => _customAvatarPath;

  bool get _firebaseReady => FirebaseService().isInitialized && FirebaseService().userId.isNotEmpty;
  bool _isFirestoreMode = false;

  MessProvider();

  StreamSubscription<auth.User?>? _authRestoreSubscription;

  @override
  void dispose() {
    _authRestoreSubscription?.cancel();
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> initialize() async {
    _authRestoreSubscription?.cancel();
    _authRestoreSubscription = null;
    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions = [];

    await _loadCustomAvatar();

    final online = await AuthModeService.isOnline();

    if (online) {
      final fs = FirebaseService();
      if (!fs.isInitialized) {
        debugPrint('Firebase not initialized - using local DB');
        _isFirestoreMode = false;
        await _loadFromDatabase();
        notifyListeners();
        return;
      }

      if (fs.userId.isNotEmpty) {
        // Already authenticated - straight to Firestore mode
        _isFirestoreMode = true;
        try {
          await _loadFromFirestore();
          _listenToFirestoreChanges();
        } catch (e) {
          debugPrint('Firestore init failed, falling back to local DB: $e');
          _isFirestoreMode = false;
          await _loadFromDatabase();
        }
        notifyListeners();
        return;
      }

      // User not authenticated yet — wait briefly then fall back to local
      // but LISTEN for late auth restoration
      try {
        final user = await fs.authStateChanges.first.timeout(const Duration(seconds: 3));
        if (user == null) throw TimeoutException('Not logged in');
        // Auth restored within 3 seconds!
        _isFirestoreMode = true;
        try {
          await _loadFromFirestore();
          _listenToFirestoreChanges();
        } catch (e) {
          debugPrint('Firestore init failed after auth restored: $e');
          _isFirestoreMode = false;
          await _loadFromDatabase();
        }
        notifyListeners();
        return;
      } catch (_) {
        // Session didn't restore within 3 seconds
        // Show local data immediately so user can use the app
        _isFirestoreMode = false;
        await _loadFromDatabase();
        notifyListeners();

        // 🔥 KEY FIX: Listen for auth to restore LATER and switch seamlessly
        _authRestoreSubscription = fs.authStateChanges.listen((user) {
          if (user != null && !_isFirestoreMode && fs.isInitialized) {
            debugPrint('Auth restored late - switching to Firestore mode');
            _switchToFirestoreMode();
          }
        });
        return;
      }
    }

    // Offline mode
    _isFirestoreMode = false;
    await _loadFromDatabase();
    notifyListeners();
  }

  bool _isSwitchingToFirestore = false;

  Future<void> _switchToFirestoreMode() async {
    if (_isSwitchingToFirestore) return;
    _isSwitchingToFirestore = true;
    _isFirestoreMode = true;
    try {
      await _loadFromFirestore();
      _listenToFirestoreChanges();
      // Only cancel listener after success so failed attempts retry
      _authRestoreSubscription?.cancel();
      _authRestoreSubscription = null;
    } catch (e) {
      debugPrint('Error switching to Firestore mode: $e');
      _isFirestoreMode = false;
    }
    _isSwitchingToFirestore = false;
    notifyListeners();
  }

  List<StreamSubscription<dynamic>> _subscriptions = [];

  void _listenToFirestoreChanges() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    _subscriptions = [];

    try {
      _subscriptions.add(
        FirebaseService().membersStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = Member.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_members.any((m) => m.id == item.id)) {
                  _members.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _members.indexWhere((m) => m.id == item.id);
                if (idx != -1) _members[idx] = item;
                break;
              case DocumentChangeType.removed:
                _members.removeWhere((m) => m.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().expensesStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = Expense.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_expenses.any((e) => e.id == item.id)) {
                  _expenses.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _expenses.indexWhere((e) => e.id == item.id);
                if (idx != -1) _expenses[idx] = item;
                break;
              case DocumentChangeType.removed:
                _expenses.removeWhere((e) => e.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().paymentsStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = Payment.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_payments.any((p) => p.id == item.id)) {
                  _payments.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _payments.indexWhere((p) => p.id == item.id);
                if (idx != -1) _payments[idx] = item;
                break;
              case DocumentChangeType.removed:
                _payments.removeWhere((p) => p.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().dailyMealsStream.listen((snapshot) {
          bool mutated = false;
          for (final change in snapshot.docChanges) {
            final item = DailyMeal.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_dailyMeals.any((d) => d.id == item.id)) {
                  _dailyMeals.add(item);
                  mutated = true;
                }
                break;
              case DocumentChangeType.modified:
                final idx = _dailyMeals.indexWhere((d) => d.id == item.id);
                if (idx != -1) {
                  final existing = _dailyMeals[idx];
                  if (existing.breakfast != item.breakfast ||
                      existing.lunch != item.lunch ||
                      existing.dinner != item.dinner) {
                    _dailyMeals[idx] = item;
                    mutated = true;
                  }
                }
                break;
              case DocumentChangeType.removed:
                _dailyMeals.removeWhere((d) => d.id == item.id);
                mutated = true;
                break;
            }
          }
          if (mutated) notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().billingCyclesStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = BillingCycle.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_billingCycles.any((c) => c.id == item.id)) {
                  _billingCycles.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _billingCycles.indexWhere((c) => c.id == item.id);
                if (idx != -1) _billingCycles[idx] = item;
                break;
              case DocumentChangeType.removed:
                _billingCycles.removeWhere((c) => c.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().shopDueItemsStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = ShopDueItem.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_shopDueItems.any((s) => s.id == item.id)) {
                  _shopDueItems.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _shopDueItems.indexWhere((s) => s.id == item.id);
                if (idx != -1) _shopDueItems[idx] = item;
                break;
              case DocumentChangeType.removed:
                _shopDueItems.removeWhere((s) => s.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().guestMealsStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = GuestMeal.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_guestMealRecords.any((g) => g.id == item.id)) {
                  _guestMealRecords.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _guestMealRecords.indexWhere((g) => g.id == item.id);
                if (idx != -1) _guestMealRecords[idx] = item;
                break;
              case DocumentChangeType.removed:
                _guestMealRecords.removeWhere((g) => g.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
      _subscriptions.add(
        FirebaseService().friedFineItemsStream.listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final item = FriedFineItem.fromMap(change.doc.data() as Map<String, dynamic>);
            switch (change.type) {
              case DocumentChangeType.added:
                if (!_friedFineItems.any((f) => f.id == item.id)) {
                  _friedFineItems.add(item);
                }
                break;
              case DocumentChangeType.modified:
                final idx = _friedFineItems.indexWhere((f) => f.id == item.id);
                if (idx != -1) _friedFineItems[idx] = item;
                break;
              case DocumentChangeType.removed:
                _friedFineItems.removeWhere((f) => f.id == item.id);
                break;
            }
          }
          notifyListeners();
        }),
      );
    } catch (e) {
      debugPrint('Error setting up Firestore listeners: $e');
      rethrow;
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      final fs = FirebaseService();
      
      // Load all 7 collections in parallel with an 8-second timeout to prevent hangs
      final results = await Future.wait([
        fs.getMembers(),
        fs.getExpenses(),
        fs.getPayments(),
        fs.getDailyMeals(),
        fs.getBillingCycles(),
        fs.getShopDueItems(),
        fs.getFriedFineItems(),
        fs.getGuestMeals(),
      ]).timeout(const Duration(seconds: 8));

      // Always clear before loading to prevent stale data when switching modes
      _members.clear();
      _members.addAll(results[0] as List<Member>);

      _expenses.clear();
      _expenses.addAll(results[1] as List<Expense>);

      _payments.clear();
      _payments.addAll(results[2] as List<Payment>);

      _dailyMeals.clear();
      _dailyMeals.addAll(results[3] as List<DailyMeal>);

      final cycles = results[4] as List<BillingCycle>;
      _billingCycles.clear();
      _billingCycles.addAll(cycles);
      final active = cycles.where((c) => c.isActive).firstOrNull;
      if (active != null) _activeCycleId = active.id;

      _shopDueItems.clear();
      _shopDueItems.addAll(results[5] as List<ShopDueItem>);

      _friedFineItems.clear();
      _friedFineItems.addAll(results[6] as List<FriedFineItem>);

      _guestMealRecords.clear();
      _guestMealRecords.addAll(results[7] as List<GuestMeal>);

      await _migrateLegacyEmptyCycleIds();
      notifyListeners();
      debugPrint('Data loaded from Firestore in parallel');
    } catch (e) {
      debugPrint('Error loading from Firestore (using local data): $e');
      rethrow;
    }
  }

  Future<void> _loadCustomAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    _customAvatarPath = prefs.getString('custom_avatar_path');
    notifyListeners();
  }

  Future<void> pickCustomAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _customAvatarPath = pickedFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_avatar_path', pickedFile.path);
      notifyListeners();
    }
  }

  // --- Local Persistence (Drift SQLite) ---
  Future<void> _loadFromDatabase() async {
    try {
      _billingCycles.clear();
      _billingCycles.addAll(await LocalDatabase.getBillingCycles());
      if (_billingCycles.isEmpty) {
        _billingCycles.add(BillingCycle(
          id: 'cycle_1', name: 'Meal 1', startDate: DateTime.now(), isActive: true,
        ));
      }

      _activeCycleId = await LocalDatabase.getActiveCycleId();
      _members.clear();
      _members.addAll(await LocalDatabase.getMembers());
      _expenses.clear();
      _expenses.addAll(await LocalDatabase.getExpenses());
      _payments.clear();
      _payments.addAll(await LocalDatabase.getPayments());
      _shopDueItems.clear();
      _shopDueItems.addAll(await LocalDatabase.getShopDueItems());
      _friedFineItems.clear();
      _friedFineItems.addAll(await LocalDatabase.getFriedFineItems());
      _guestMealRecords.clear();
      _guestMealRecords.addAll(await LocalDatabase.getGuestMeals());
      _dailyMeals.clear();
      _dailyMeals.addAll(await LocalDatabase.getDailyMeals());

      // If database was empty, migrate from SharedPreferences
      if (_members.isEmpty && _expenses.isEmpty) {
        await _migrateFromPrefs();
      }

      await _migrateLegacyEmptyCycleIds();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading from database: $e');
      await _migrateFromPrefs();
    }
  }

  Future<void> _migrateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool hasData = false;

      final cyclesString = prefs.getString('mess_billing_cycles');
      if (cyclesString != null) {
        final List<dynamic> decoded = json.decode(cyclesString);
        _billingCycles.clear();
        _billingCycles.addAll(decoded.map((c) => BillingCycle.fromMap(c)).toList());
        hasData = true;
      }
      _activeCycleId = prefs.getString('mess_active_cycle_id') ?? 'cycle_1';

      final membersString = prefs.getString('mess_members');
      if (membersString != null) {
        final List<dynamic> decoded = json.decode(membersString);
        _members.clear();
        _members.addAll(decoded.map((m) => Member.fromMap(m)).toList());
        hasData = true;
      }

      final expensesString = prefs.getString('mess_expenses');
      if (expensesString != null) {
        final List<dynamic> decoded = json.decode(expensesString);
        _expenses.clear();
        _expenses.addAll(decoded.map((e) => Expense.fromMap(e)).toList());
      }

      final paymentsString = prefs.getString('mess_payments');
      if (paymentsString != null) {
        final List<dynamic> decoded = json.decode(paymentsString);
        _payments.clear();
        _payments.addAll(decoded.map((p) => Payment.fromMap(p)).toList());
      }

      final shopDueString = prefs.getString('mess_shop_due');
      if (shopDueString != null) {
        final List<dynamic> decoded = json.decode(shopDueString);
        _shopDueItems.clear();
        _shopDueItems.addAll(decoded.map((s) => ShopDueItem.fromMap(s)).toList());
      }

      final friedFineString = prefs.getString('mess_fried_fine');
      if (friedFineString != null) {
        final List<dynamic> decoded = json.decode(friedFineString);
        _friedFineItems.clear();
        _friedFineItems.addAll(decoded.map((f) => FriedFineItem.fromMap(f)).toList());
      }

      final guestMealsString = prefs.getString('mess_guest_meals');
      if (guestMealsString != null) {
        final List<dynamic> decoded = json.decode(guestMealsString);
        _guestMealRecords.clear();
        _guestMealRecords.addAll(decoded.map((g) => GuestMeal.fromMap(g)).toList());
      }

      final dailyMealsString = prefs.getString('mess_daily_meals');
      if (dailyMealsString != null) {
        final List<dynamic> decoded = json.decode(dailyMealsString);
        _dailyMeals.clear();
        _dailyMeals.addAll(decoded.map((d) => DailyMeal.fromMap(d)).toList());
      }

      if (hasData) {
        await _saveToDatabase();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error migrating from SharedPreferences: $e');
    }
  }

  Future<void> _migrateLegacyEmptyCycleIds() async {
    if (_activeCycleId.isEmpty) return;
    bool needsUpdate = false;
    for (int i = 0; i < _members.length; i++) {
      if (_members[i].cycleId.isEmpty) {
        _members[i] = _members[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().saveMember(_members[i]);
        needsUpdate = true;
      }
    }
    for (int i = 0; i < _expenses.length; i++) {
      if (_expenses[i].cycleId.isEmpty) {
        _expenses[i] = _expenses[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().saveExpense(_expenses[i]);
        needsUpdate = true;
      }
    }
    for (int i = 0; i < _payments.length; i++) {
      if (_payments[i].cycleId.isEmpty) {
        _payments[i] = _payments[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().savePayment(_payments[i]);
        needsUpdate = true;
      }
    }
    for (int i = 0; i < _dailyMeals.length; i++) {
      if (_dailyMeals[i].cycleId.isEmpty) {
        _dailyMeals[i] = _dailyMeals[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().saveDailyMeal(_dailyMeals[i]);
        needsUpdate = true;
      }
    }
    for (int i = 0; i < _shopDueItems.length; i++) {
      if (_shopDueItems[i].cycleId.isEmpty) {
        _shopDueItems[i] = _shopDueItems[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().saveShopDueItem(_shopDueItems[i]);
        needsUpdate = true;
      }
    }
    for (int i = 0; i < _friedFineItems.length; i++) {
      if (_friedFineItems[i].cycleId.isEmpty) {
        _friedFineItems[i] = _friedFineItems[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().saveFriedFineItem(_friedFineItems[i]);
        needsUpdate = true;
      }
    }
    for (int i = 0; i < _guestMealRecords.length; i++) {
      if (_guestMealRecords[i].cycleId.isEmpty) {
        _guestMealRecords[i] = _guestMealRecords[i].copyWith(cycleId: _activeCycleId);
        if (_isFirestoreMode) FirebaseService().saveGuestMeal(_guestMealRecords[i]);
        needsUpdate = true;
      }
    }
    if (needsUpdate && !_isFirestoreMode) {
      await _saveToDatabase();
    }
    if (needsUpdate) debugPrint('Legacy items migrated to active cycle $_activeCycleId.');
  }

  Future<void> _saveToDatabase() async {
    if (_isFirestoreMode) return;
    try {
      await LocalDatabase.saveAll(
        billingCycles: _billingCycles,
        members: _members,
        expenses: _expenses,
        payments: _payments,
        shopDueItems: _shopDueItems,
        friedFineItems: _friedFineItems,
        guestMeals: _guestMealRecords,
        dailyMeals: _dailyMeals,
        activeCycleId: _activeCycleId,
      );
    } catch (e) {
      debugPrint('Error saving to database: $e');
    }
  }

  // --- Cycle Getters & Setters ---
  List<BillingCycle> get billingCycles => _billingCycles;
  String get activeCycleId => _activeCycleId;
  
  void setActiveCycle(String cycleId) {
    for (int i = 0; i < _billingCycles.length; i++) {
      if (_billingCycles[i].id == cycleId) {
        _billingCycles[i] = _billingCycles[i].copyWith(isActive: true);
      } else {
        _billingCycles[i] = _billingCycles[i].copyWith(
          isActive: false,
          endDate: _billingCycles[i].endDate ?? DateTime.now(),
        );
      }
    }
    _activeCycleId = cycleId;
    if (_isFirestoreMode) {
      for (final c in _billingCycles) {
        FirebaseService().saveBillingCycle(c);
      }
    } else {
      _saveToDatabase();
    }
    notifyListeners();
  }

  // --- Cached Values for Performance Optimization ---
  List<Member> _cachedMembers = [];
  double _cachedShopDue = 0.0;
  double _cachedTotalExpenses = 0.0;
  double _cachedTotalPayments = 0.0;
  double _cachedTotalMeals = 0.0;
  double _cachedMealRate = 0.0;
  int _cachedTotalActiveMembers = 0;
  int _cachedTodayActiveMembers = 0;
  double _cachedMealsToday = 0.0;
  double _cachedTotalFriedFine = 0.0;

  @override
  void notifyListeners() {
    _recalculateTotals();
    super.notifyListeners();
  }

  void _recalculateTotals() {
    final String currentCycleId = _activeCycleId;
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Calculate Members (Heavy loop)
    _cachedMembers = _members.where((m) => m.cycleId == currentCycleId).map((member) {
      double mealsCount = 0.0;
      final memberMeals = _dailyMeals.where((dm) => dm.memberId == member.id && (dm.cycleId == currentCycleId));
      for (var dm in memberMeals) {
        mealsCount += (dm.breakfast ? 1.0 : 0.0) + (dm.lunch ? 1.0 : 0.0) + (dm.dinner ? 1.0 : 0.0);
      }
      double paymentsCount = _payments
          .where((p) => p.memberId == member.id && (p.cycleId == currentCycleId))
          .fold(0.0, (sum, item) => sum + item.amount);
          
      double finesCount = _friedFineItems
          .where((f) => f.memberId == member.id && (f.cycleId == currentCycleId))
          .fold(0.0, (sum, item) => sum + item.amount);

      double guestMealsCount = _guestMealRecords
          .where((g) => g.memberId == member.id && (g.cycleId == currentCycleId))
          .fold(0.0, (sum, item) => sum + (item.count).toDouble());
          
      return member.copyWith(
        totalMeals: mealsCount, 
        guestMeals: guestMealsCount,
        payments: paymentsCount,
        friedFine: finesCount,
      );
    }).toList();

    // 2. Simple folds
    _cachedShopDue = _shopDueItems
        .where((s) => s.cycleId == currentCycleId)
        .fold(0.0, (sum, item) => sum + item.amount);

    _cachedTotalExpenses = _expenses
        .where((e) => e.cycleId == currentCycleId)
        .fold(0.0, (sum, item) => sum + item.amount);

    _cachedTotalPayments = _payments
        .where((p) => p.cycleId == currentCycleId)
        .fold(0.0, (sum, item) => sum + item.amount);

    _cachedTotalFriedFine = _friedFineItems
        .where((item) => item.cycleId == currentCycleId)
        .fold(0.0, (sum, item) => sum + item.amount);

    // 3. Dependent calculations
    _cachedTotalMeals = _cachedMembers.fold(0.0, (sum, item) => sum + item.totalMeals);
    _cachedMealRate = _cachedTotalMeals == 0 ? 0.0 : _cachedTotalExpenses / _cachedTotalMeals;

    // 4. Today calculations
    _cachedTotalActiveMembers = _cachedMembers.where((m) => m.isActive).length;

    int todayActive = 0;
    double todayMealsSum = 0.0;
    final todayMealsList = _dailyMeals.where((dm) => dm.dateString == todayString && (dm.cycleId == currentCycleId)).toList();
    
    for (var m in _cachedMembers) {
      if (m.isActive) {
        final dm = todayMealsList.firstWhere(
          (d) => d.memberId == m.id,
          orElse: () => DailyMeal(id: '', memberId: m.id, dateString: todayString, cycleId: currentCycleId),
        );
        if (dm.breakfast || dm.lunch || dm.dinner) {
          todayActive++;
        }
        todayMealsSum += (dm.breakfast ? 1.0 : 0.0) + (dm.lunch ? 1.0 : 0.0) + (dm.dinner ? 1.0 : 0.0);
      }
    }
    _cachedTodayActiveMembers = todayActive;
    _cachedMealsToday = todayMealsSum;
  }

  // Get members with dynamic meal count and payment summation for the active cycle
  List<Member> get members => _cachedMembers;

  // Raw unfiltered getters (used internally / for cross-cycle views)
  List<Member> get allMembers => _members;
  List<Expense> get allExpenses => _expenses;
  List<Payment> get allPayments => _payments;
  List<ShopDueItem> get allShopDueItems => _shopDueItems;
  List<FriedFineItem> get allFriedFineItems => _friedFineItems;
  List<DailyMeal> get dailyMeals => _dailyMeals;

  List<GuestMeal> get guestMeals =>
      _guestMealRecords.where((g) => g.cycleId == _activeCycleId).toList();

  // Cycle-filtered getters — also include items with empty cycleId (legacy data)
  List<Expense> get expenses =>
      _expenses.where((e) => e.cycleId == _activeCycleId).toList();

  List<Payment> get payments =>
      _payments.where((p) => p.cycleId == _activeCycleId).toList();

  List<ShopDueItem> get shopDueItems =>
      _shopDueItems.where((s) => s.cycleId == _activeCycleId).toList();

  List<FriedFineItem> get friedFineItems =>
      _friedFineItems.where((f) => f.cycleId == _activeCycleId).toList();

  double get shopDue => _cachedShopDue;

  // Cycle-specific Calculations
  double get totalExpenses => _cachedTotalExpenses;
  double get totalPayments => _cachedTotalPayments;
  double get totalMeals => _cachedTotalMeals;
  double get mealRate => _cachedMealRate;
  int get totalActiveMembers => _cachedTotalActiveMembers;
  int get todayActiveMembers => _cachedTodayActiveMembers;
  double get mealsToday => _cachedMealsToday;
  double get totalFriedFine => _cachedTotalFriedFine;

  double getMemberBazarSpent(String memberId) {
    final String currentCycleId = _activeCycleId;
    return _expenses
        .where((e) => e.buyerId == memberId && (e.cycleId == currentCycleId))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Get balance for specific member (Payments - Bill)
  // Guest meals are charged at the same meal rate — member pays for the guests they bring
  double getMemberBalance(Member member) {
    double totalCredit = member.payments;
    double totalCost = (member.totalMeals + member.guestMeals) * mealRate;
    return totalCredit - totalCost;
  }

  // Current logged in user
  Member get currentUser {
    if (_firebaseReady) {
      final u = FirebaseService().currentUser;
      if (u != null) {
        return Member(
          id: u.uid,
          name: u.displayName ?? 'User',
          email: u.email ?? '',
          imageUrl: u.photoURL ?? '',
          cycleId: _activeCycleId,
        );
      }
    }
    return Member(
      id: 'offline',
      name: 'User',
      email: 'Offline Mode',
      imageUrl: '',
      cycleId: _activeCycleId,
    );
  }

  // --- Mutations ---

  void closeActiveCycle(String nameForClosedCycle) {
    final index = _billingCycles.indexWhere((c) => c.id == _activeCycleId);
    if (index != -1) {
      _billingCycles[index] = _billingCycles[index].copyWith(
        name: nameForClosedCycle,
        endDate: DateTime.now(),
        isActive: false,
      );
    }
    final newCycleId = 'cycle_${DateTime.now().millisecondsSinceEpoch}';
    final newCycle = BillingCycle(
      id: newCycleId,
      name: 'Meal ${(_billingCycles.length + 1)}',
      startDate: DateTime.now(),
      isActive: true,
    );
    _billingCycles.add(newCycle);
    _activeCycleId = newCycleId;
    if (_isFirestoreMode) {
      for (final c in _billingCycles) {
        FirebaseService().saveBillingCycle(c);
      }
    } else {
      _saveToDatabase();
    }
    notifyListeners();
  }

  void addExpense(Expense expense) {
    final e = expense.copyWith(cycleId: _activeCycleId);
    _expenses.add(e);
    if (_isFirestoreMode) {
      FirebaseService().saveExpense(e);
    } else {
      LocalDatabase.insertExpense(e);
    }
    notifyListeners();
  }

  void addPayment(Payment payment) {
    final p = payment.copyWith(cycleId: _activeCycleId);
    _payments.add(p);
    if (_isFirestoreMode) {
      FirebaseService().savePayment(p);
    } else {
      LocalDatabase.insertPayment(p);
    }
    notifyListeners();
  }

  void addMember(Member member) {
    final m = member.copyWith(cycleId: _activeCycleId);
    _members.add(m);
    if (_isFirestoreMode) {
      FirebaseService().saveMember(m);
    } else {
      LocalDatabase.insertMember(m);
    }
    notifyListeners();
  }

  void toggleDailyMeal(String memberId, String dateString, String mealType, bool value) {
    final index = _dailyMeals.indexWhere((dm) => dm.memberId == memberId && dm.dateString == dateString && dm.cycleId == _activeCycleId);
    DailyMeal meal;
    if (index != -1) {
      final old = _dailyMeals[index];
      DailyMeal updated = old;
      if (mealType == 'B') updated = old.copyWith(breakfast: value);
      if (mealType == 'L') updated = old.copyWith(lunch: value);
      if (mealType == 'D') updated = old.copyWith(dinner: value);
      _dailyMeals[index] = updated;
      meal = updated;
    } else {
      meal = DailyMeal(
        id: '${DateTime.now().millisecondsSinceEpoch}_$memberId',
        memberId: memberId,
        dateString: dateString,
        breakfast: mealType == 'B' ? value : false,
        lunch: mealType == 'L' ? value : false,
        dinner: mealType == 'D' ? value : false,
        cycleId: _activeCycleId,
      );
      _dailyMeals.add(meal);
    }
    if (_isFirestoreMode) {
      FirebaseService().saveDailyMeal(meal);
    } else {
      LocalDatabase.insertDailyMeal(meal);
    }
    notifyListeners();
  }

  void toggleAllDailyMeals(List<String> memberIds, String dateString, bool checkAll) {
    final List<DailyMeal> changed = [];
    for (var memberId in memberIds) {
      final index = _dailyMeals.indexWhere((dm) => dm.memberId == memberId && dm.dateString == dateString && dm.cycleId == _activeCycleId);
      if (index != -1) {
        _dailyMeals[index] = _dailyMeals[index].copyWith(
          breakfast: checkAll, lunch: checkAll, dinner: checkAll,
        );
        changed.add(_dailyMeals[index]);
      } else {
        final meal = DailyMeal(
          id: '${DateTime.now().millisecondsSinceEpoch}_$memberId',
          memberId: memberId, dateString: dateString,
          breakfast: checkAll, lunch: checkAll, dinner: checkAll,
          cycleId: _activeCycleId,
        );
        _dailyMeals.add(meal);
        changed.add(meal);
      }
    }
    if (_isFirestoreMode) {
      // Use batch write: ONE Firestore commit instead of N individual saves.
      // This fires ONE snapshot event (not N), preventing rapid rebuilds.
      FirebaseService().saveDataBatch(dailyMeals: changed);
    } else {
      for (final m in changed) {
        LocalDatabase.insertDailyMeal(m);
      }
    }
    notifyListeners();
  }

  // --- Guest Meals Management ---
  
  List<GuestMeal> getGuestMealsForDate(String dateString) {
    return _guestMealRecords.where((g) => 
      g.dateString == dateString && 
      (g.cycleId == _activeCycleId)
    ).toList();
  }

  int getGuestMealCountForMember(String memberId, String dateString) {
    final existing = _guestMealRecords.where((g) =>
      g.memberId == memberId &&
      g.dateString == dateString &&
      (g.cycleId == _activeCycleId)
    ).toList();
    if (existing.isNotEmpty) {
      return existing.first.count;
    }
    return 0;
  }

  void setGuestMealForMember(String memberId, String dateString, int count) {
    // Remove existing record for this member+date
    _guestMealRecords.removeWhere((g) =>
      g.memberId == memberId &&
      g.dateString == dateString &&
      g.cycleId == _activeCycleId
    );
    
    if (count > 0) {
      final record = GuestMeal(
        id: 'gm_${memberId}_$dateString',
        memberId: memberId,
        dateString: dateString,
        count: count,
        cycleId: _activeCycleId,
      );
      _guestMealRecords.add(record);
      if (_isFirestoreMode) {
        FirebaseService().saveGuestMeal(record);
      } else {
        LocalDatabase.insertGuestMeal(record);
      }
    } else {
      // Remove from DB/Firestore if count is 0
      if (_isFirestoreMode) {
        FirebaseService().deleteGuestMealDoc('gm_${memberId}_$dateString');
      } else {
        LocalDatabase.deleteGuestMeal('gm_${memberId}_$dateString');
      }
    }
    notifyListeners();
  }

  void clearAllGuestMealsForDate(String dateString) {
    final removed = _guestMealRecords.where((g) =>
      g.dateString == dateString &&
      g.cycleId == _activeCycleId
    ).toList();
    _guestMealRecords.removeWhere((g) =>
      g.dateString == dateString &&
      g.cycleId == _activeCycleId
    );
    for (final g in removed) {
      if (_isFirestoreMode) {
        FirebaseService().deleteGuestMealDoc(g.id);
      } else {
        LocalDatabase.deleteGuestMeal(g.id);
      }
    }
    notifyListeners();
  }

  void updateMemberMeals(String memberId, double meals) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(totalMeals: meals);
      if (_isFirestoreMode) {
        FirebaseService().saveMember(_members[index]);
      } else {
        LocalDatabase.insertMember(_members[index]);
      }
      notifyListeners();
    }
  }

  void toggleMemberActiveStatus(String memberId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(isActive: !_members[index].isActive);
      if (_isFirestoreMode) {
        FirebaseService().saveMember(_members[index]);
      } else {
        LocalDatabase.insertMember(_members[index]);
      }
      notifyListeners();
    }
  }

  void toggleMemberActiveToday(String memberId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(isActiveToday: !_members[index].isActiveToday);
      if (_isFirestoreMode) {
        FirebaseService().saveMember(_members[index]);
      } else {
        LocalDatabase.insertMember(_members[index]);
      }
      notifyListeners();
    }
  }

  @Deprecated('Use addShopDueItem/deleteShopDueItem instead. This replaces ALL items.')
  void updateShopDue(double due) {
    final oldItems = List<ShopDueItem>.from(_shopDueItems);
    _shopDueItems.clear();
    final item = ShopDueItem(
      id: 'sd_manual', title: 'Manual Entry', amount: due,
      date: DateTime.now(),
      buyerId: _members.isNotEmpty ? _members[0].id : '',
      cycleId: _activeCycleId,
    );
    _shopDueItems.add(item);
    if (_isFirestoreMode) {
      for (final old in oldItems) {
        FirebaseService().deleteShopDueItemDoc(old.id);
      }
      FirebaseService().saveShopDueItem(item);
    } else {
      _saveToDatabase();
    }
    notifyListeners();
  }

  void _syncMemberFriedFine(String memberId) {
    final total = _friedFineItems
        .where((item) => item.memberId == memberId && (item.cycleId == _activeCycleId))
        .fold(0.0, (sum, item) => sum + item.amount);
    final memberIndex = _members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      _members[memberIndex] = _members[memberIndex].copyWith(friedFine: total);
      if (_isFirestoreMode) {
        FirebaseService().saveMember(_members[memberIndex]);
      } else {
        LocalDatabase.insertMember(_members[memberIndex]);
      }
    }
  }

  void updateMemberFriedFine(String memberId, double amount) {
    if (_isFirestoreMode) {
      final removed = _friedFineItems.where((item) => item.memberId == memberId && item.cycleId == _activeCycleId).toList();
      for (final item in removed) {
        FirebaseService().deleteFriedFineItemDoc(item.id);
      }
    }
    _friedFineItems.removeWhere((item) => item.memberId == memberId && item.cycleId == _activeCycleId);
    if (amount > 0) {
      final item = FriedFineItem(
        id: 'ff_manual_${DateTime.now().millisecondsSinceEpoch}',
        memberId: memberId, amount: amount, date: DateTime.now(),
        cycleId: _activeCycleId,
      );
      _friedFineItems.add(item);
      if (_isFirestoreMode) {
        FirebaseService().saveFriedFineItem(item);
      }
    }
    _syncMemberFriedFine(memberId);
    notifyListeners();
  }

  void deleteMember(String memberId) {
    final removedMeals = _dailyMeals.where((dm) => dm.memberId == memberId).toList();
    final removedPayments = _payments.where((p) => p.memberId == memberId).toList();
    final removedFines = _friedFineItems.where((f) => f.memberId == memberId).toList();
    final removedGuestMeals = _guestMealRecords.where((g) => g.memberId == memberId).toList();
    final removedExpenses = _expenses.where((e) => e.buyerId == memberId).toList();
    final removedShopDues = _shopDueItems.where((s) => s.buyerId == memberId).toList();
    _members.removeWhere((m) => m.id == memberId);
    _dailyMeals.removeWhere((dm) => dm.memberId == memberId);
    _payments.removeWhere((p) => p.memberId == memberId);
    _friedFineItems.removeWhere((f) => f.memberId == memberId);
    _guestMealRecords.removeWhere((g) => g.memberId == memberId);
    _expenses.removeWhere((e) => e.buyerId == memberId);
    _shopDueItems.removeWhere((s) => s.buyerId == memberId);
    if (_isFirestoreMode) {
      FirebaseService().deleteMemberDoc(memberId);
      for (final meal in removedMeals) {
        FirebaseService().deleteDailyMealDoc(meal.id);
      }
      for (final p in removedPayments) {
        FirebaseService().deletePaymentDoc(p.id);
      }
      for (final f in removedFines) {
        FirebaseService().deleteFriedFineItemDoc(f.id);
      }
      for (final g in removedGuestMeals) {
        FirebaseService().deleteGuestMealDoc(g.id);
      }
      for (final e in removedExpenses) {
        FirebaseService().deleteExpenseDoc(e.id);
      }
      for (final s in removedShopDues) {
        FirebaseService().deleteShopDueItemDoc(s.id);
      }
    } else {
      LocalDatabase.deleteMember(memberId);
      for (final meal in removedMeals) {
        LocalDatabase.deleteDailyMeal(meal.id);
      }
      for (final p in removedPayments) {
        LocalDatabase.deletePayment(p.id);
      }
      for (final f in removedFines) {
        LocalDatabase.deleteFriedFineItem(f.id);
      }
      for (final g in removedGuestMeals) {
        LocalDatabase.deleteGuestMeal(g.id);
      }
      for (final e in removedExpenses) {
        LocalDatabase.deleteExpense(e.id);
      }
      for (final s in removedShopDues) {
        LocalDatabase.deleteShopDueItem(s.id);
      }
    }
    notifyListeners();
  }

  void updateMemberDetails(String memberId, String name, String phone, String roomNumber) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(name: name, phone: phone, roomNumber: roomNumber);
      if (_isFirestoreMode) {
        FirebaseService().saveMember(_members[index]);
      } else {
        LocalDatabase.insertMember(_members[index]);
      }
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    if (_isFirestoreMode) {
      FirebaseService().deleteExpenseDoc(expenseId);
    } else {
      LocalDatabase.deleteExpense(expenseId);
    }
    notifyListeners();
  }

  void updateExpense(String expenseId, String title, double amount, String buyerId) {
    final index = _expenses.indexWhere((e) => e.id == expenseId);
    if (index != -1) {
      _expenses[index] = Expense(
        id: expenseId, title: title, amount: amount,
        date: _expenses[index].date, buyerId: buyerId,
        cycleId: _expenses[index].cycleId,
      );
      if (_isFirestoreMode) {
        FirebaseService().saveExpense(_expenses[index]);
      } else {
        LocalDatabase.insertExpense(_expenses[index]);
      }
      notifyListeners();
    }
  }

  void addShopDueItem(ShopDueItem item) {
    final s = item.copyWith(cycleId: _activeCycleId);
    _shopDueItems.add(s);
    if (_isFirestoreMode) {
      FirebaseService().saveShopDueItem(s);
    } else {
      LocalDatabase.insertShopDueItem(s);
    }
    notifyListeners();
  }

  void deleteShopDueItem(String itemId) {
    _shopDueItems.removeWhere((i) => i.id == itemId);
    if (_isFirestoreMode) {
      FirebaseService().deleteShopDueItemDoc(itemId);
    } else {
      LocalDatabase.deleteShopDueItem(itemId);
    }
    notifyListeners();
  }

  void updateShopDueItem(String itemId, String title, double amount, String buyerId) {
    final index = _shopDueItems.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _shopDueItems[index] = _shopDueItems[index].copyWith(title: title, amount: amount, buyerId: buyerId);
      if (_isFirestoreMode) {
        FirebaseService().saveShopDueItem(_shopDueItems[index]);
      } else {
        LocalDatabase.insertShopDueItem(_shopDueItems[index]);
      }
      notifyListeners();
    }
  }

  void deletePayment(String paymentId) {
    final paymentIndex = _payments.indexWhere((p) => p.id == paymentId);
    if (paymentIndex != -1) {
      _payments.removeAt(paymentIndex);
      if (_isFirestoreMode) {
        FirebaseService().deletePaymentDoc(paymentId);
      } else {
        LocalDatabase.deletePayment(paymentId);
      }
      notifyListeners();
    }
  }

  void updatePayment(String paymentId, String memberId, double amount) {
    final paymentIndex = _payments.indexWhere((p) => p.id == paymentId);
    if (paymentIndex != -1) {
      final oldPayment = _payments[paymentIndex];
      _payments[paymentIndex] = Payment(
        id: paymentId, memberId: memberId, amount: amount,
        date: oldPayment.date, cycleId: oldPayment.cycleId,
      );
      if (_isFirestoreMode) {
        FirebaseService().savePayment(_payments[paymentIndex]);
      } else {
        LocalDatabase.insertPayment(_payments[paymentIndex]);
      }
      notifyListeners();
    }
  }

  void addFriedFineItem(String memberId, double amount) {
    final item = FriedFineItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_friedFineItems.length}',
      memberId: memberId, amount: amount, date: DateTime.now(),
      cycleId: _activeCycleId,
    );
    _friedFineItems.add(item);
    if (_isFirestoreMode) {
      FirebaseService().saveFriedFineItem(item);
    } else {
      LocalDatabase.insertFriedFineItem(item);
    }
    _syncMemberFriedFine(memberId);
    notifyListeners();
  }

  void deleteFriedFineItem(String itemId) {
    final index = _friedFineItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final memberId = _friedFineItems[index].memberId;
      _friedFineItems.removeAt(index);
      if (_isFirestoreMode) {
        FirebaseService().deleteFriedFineItemDoc(itemId);
      } else {
        LocalDatabase.deleteFriedFineItem(itemId);
      }
      _syncMemberFriedFine(memberId);
      notifyListeners();
    }
  }

  void clearMemberFriedFine(String memberId) {
    final removed = _friedFineItems.where((item) => item.memberId == memberId && item.cycleId == _activeCycleId).toList();
    _friedFineItems.removeWhere((item) => item.memberId == memberId && item.cycleId == _activeCycleId);
    for (final item in removed) {
      if (_isFirestoreMode) {
        FirebaseService().deleteFriedFineItemDoc(item.id);
      } else {
        LocalDatabase.deleteFriedFineItem(item.id);
      }
    }
    _syncMemberFriedFine(memberId);
    notifyListeners();
  }

  Map<String, DateTime> getCycleActiveDateRange(String cycleId) {
    final cycle = _billingCycles.firstWhere(
      (c) => c.id == cycleId,
      orElse: () => BillingCycle(id: cycleId, name: 'Meal', startDate: DateTime.now(), isActive: true),
    );

    final activeMeals = _dailyMeals.where((m) => m.cycleId == cycleId && (m.breakfast || m.lunch || m.dinner)).toList();

    DateTime start = cycle.startDate;
    DateTime end = cycle.endDate ?? DateTime.now();

    if (activeMeals.isNotEmpty) {
      try {
        final dates = activeMeals.map((m) => DateTime.parse(m.dateString)).toList();
        dates.sort();
        start = dates.first;
        end = dates.last;
      } catch (_) {}
    }

    return {'start': start, 'end': end};
  }

  void deleteBillingCycle(String cycleId) {
    if (_billingCycles.length <= 1) {
      return;
    }

    if (_activeCycleId == cycleId) {
      final otherCycle = _billingCycles.firstWhere((c) => c.id != cycleId);
      _activeCycleId = otherCycle.id;
    }

    if (_isFirestoreMode) {
      FirebaseService().deleteCycleDoc(cycleId);
      
      final cycleMembers = _members.where((m) => m.cycleId == cycleId).toList();
      for (final m in cycleMembers) {
        FirebaseService().deleteMemberDoc(m.id);
      }
      
      final cycleMeals = _dailyMeals.where((dm) => dm.cycleId == cycleId).toList();
      for (final meal in cycleMeals) {
        FirebaseService().deleteDailyMealDoc(meal.id);
      }
      
      final cyclePayments = _payments.where((p) => p.cycleId == cycleId).toList();
      for (final p in cyclePayments) {
        FirebaseService().deletePaymentDoc(p.id);
      }
      
      final cycleExpenses = _expenses.where((e) => e.cycleId == cycleId).toList();
      for (final e in cycleExpenses) {
        FirebaseService().deleteExpenseDoc(e.id);
      }
      
      final cycleShopDues = _shopDueItems.where((s) => s.cycleId == cycleId).toList();
      for (final s in cycleShopDues) {
        FirebaseService().deleteShopDueItemDoc(s.id);
      }
      
      final cycleFines = _friedFineItems.where((f) => f.cycleId == cycleId).toList();
      for (final f in cycleFines) {
        FirebaseService().deleteFriedFineItemDoc(f.id);
      }

      final cycleGuestMeals = _guestMealRecords.where((g) => g.cycleId == cycleId).toList();
      for (final g in cycleGuestMeals) {
        FirebaseService().deleteGuestMealDoc(g.id);
      }
    }

    _billingCycles.removeWhere((c) => c.id == cycleId);
    _members.removeWhere((m) => m.cycleId == cycleId);
    _dailyMeals.removeWhere((dm) => dm.cycleId == cycleId);
    _payments.removeWhere((p) => p.cycleId == cycleId);
    _expenses.removeWhere((e) => e.cycleId == cycleId);
    _shopDueItems.removeWhere((s) => s.cycleId == cycleId);
    _friedFineItems.removeWhere((f) => f.cycleId == cycleId);
    _guestMealRecords.removeWhere((g) => g.cycleId == cycleId);

    if (!_isFirestoreMode) {
      _saveToDatabase();
    }

    notifyListeners();
  }
}

