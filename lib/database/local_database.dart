import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/mess_data.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    sqfliteFfiInit();
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'mess_manager.db');
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE members ADD COLUMN cycleId TEXT NOT NULL DEFAULT ""');
          }
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE IF NOT EXISTS guest_meals (
                id TEXT PRIMARY KEY,
                memberId TEXT NOT NULL,
                dateString TEXT NOT NULL,
                count INTEGER NOT NULL DEFAULT 0,
                cycleId TEXT NOT NULL DEFAULT ''
              )
            ''');
          }
        },
        onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS billing_cycles (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT,
            isActive INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS members (
            id TEXT NOT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL DEFAULT '',
            imageUrl TEXT NOT NULL DEFAULT '',
            isActive INTEGER NOT NULL DEFAULT 1,
            isActiveToday INTEGER NOT NULL DEFAULT 1,
            totalMeals REAL NOT NULL DEFAULT 0.0,
            payments REAL NOT NULL DEFAULT 0.0,
            individualExpenses REAL NOT NULL DEFAULT 0.0,
            friedFine REAL NOT NULL DEFAULT 0.0,
            phone TEXT NOT NULL DEFAULT '',
            roomNumber TEXT NOT NULL DEFAULT '',
            cycleId TEXT NOT NULL DEFAULT '',
            PRIMARY KEY (id, cycleId)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            buyerId TEXT NOT NULL,
            cycleId TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS payments (
            id TEXT PRIMARY KEY,
            memberId TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            cycleId TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS shop_due_items (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            buyerId TEXT NOT NULL,
            cycleId TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS fried_fine_items (
            id TEXT PRIMARY KEY,
            memberId TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            cycleId TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS guest_meals (
            id TEXT PRIMARY KEY,
            memberId TEXT NOT NULL,
            dateString TEXT NOT NULL,
            count INTEGER NOT NULL DEFAULT 0,
            cycleId TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_meals (
            id TEXT PRIMARY KEY,
            memberId TEXT NOT NULL,
            dateString TEXT NOT NULL,
            breakfast INTEGER NOT NULL DEFAULT 0,
            lunch INTEGER NOT NULL DEFAULT 0,
            dinner INTEGER NOT NULL DEFAULT 0,
            cycleId TEXT NOT NULL DEFAULT ''
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS app_state (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    ),
  );
  }

  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  // ---- app_state helpers ----
  static Future<String?> getState(String key) async {
    final db = await instance;
    final result = await db.query('app_state', where: '"key" = ?', whereArgs: [key]);
    if (result.isNotEmpty) return result.first['value'] as String?;
    return null;
  }

  static Future<void> setState(String key, String value) async {
    final db = await instance;
    await db.insert('app_state', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---- Billing Cycles ----
  static Future<List<BillingCycle>> getBillingCycles() async {
    final db = await instance;
    final rows = await db.query('billing_cycles');
    return rows.map((r) => _billingCycleFromRow(r)).toList();
  }

  static Future<void> saveBillingCycles(List<BillingCycle> cycles) async {
    final db = await instance;
    await db.delete('billing_cycles');
    for (final c in cycles) {
      await db.insert('billing_cycles', _billingCycleToRow(c));
    }
  }

  static Map<String, dynamic> _billingCycleToRow(BillingCycle c) => {
    'id': c.id,
    'name': c.name,
    'startDate': c.startDate.toIso8601String(),
    'endDate': c.endDate?.toIso8601String(),
    'isActive': c.isActive ? 1 : 0,
  };

  static BillingCycle _billingCycleFromRow(Map<String, dynamic> r) => BillingCycle(
    id: r['id'] as String,
    name: r['name'] as String,
    startDate: DateTime.parse(r['startDate'] as String),
    endDate: r['endDate'] != null ? DateTime.parse(r['endDate'] as String) : null,
    isActive: (r['isActive'] as int) == 1,
  );

  // ---- Members ----
  static Future<List<Member>> getMembers() async {
    final db = await instance;
    final rows = await db.query('members');
    return rows.map((r) => Member.fromMap({
      'id': r['id'],
      'name': r['name'],
      'email': r['email'],
      'imageUrl': r['imageUrl'],
      'isActive': (r['isActive'] as int) == 1,
      'isActiveToday': (r['isActiveToday'] as int) == 1,
      'totalMeals': r['totalMeals'],
      'payments': r['payments'],
      'individualExpenses': r['individualExpenses'],
      'friedFine': r['friedFine'],
      'phone': r['phone'],
      'roomNumber': r['roomNumber'],
      'cycleId': r['cycleId'] ?? '',
    })).toList();
  }

  static Future<void> saveMembers(List<Member> members) async {
    final db = await instance;
    await db.delete('members');
    for (final m in members) {
      await db.insert('members', {
        'id': m.id,
        'name': m.name,
        'email': m.email,
        'imageUrl': m.imageUrl,
        'isActive': m.isActive ? 1 : 0,
        'isActiveToday': m.isActiveToday ? 1 : 0,
        'totalMeals': m.totalMeals,
        'payments': m.payments,
        'individualExpenses': m.individualExpenses,
        'friedFine': m.friedFine,
        'phone': m.phone,
        'roomNumber': m.roomNumber,
        'cycleId': m.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertMember(Member member) async {
    final db = await instance;
    await db.insert('members', {
      'id': member.id,
      'name': member.name,
      'email': member.email,
      'imageUrl': member.imageUrl,
      'isActive': member.isActive ? 1 : 0,
      'isActiveToday': member.isActiveToday ? 1 : 0,
      'totalMeals': member.totalMeals,
      'payments': member.payments,
      'individualExpenses': member.individualExpenses,
      'friedFine': member.friedFine,
      'phone': member.phone,
      'roomNumber': member.roomNumber,
      'cycleId': member.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteMember(String id) async {
    final db = await instance;
    await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Expenses ----
  static Future<List<Expense>> getExpenses() async {
    final db = await instance;
    final rows = await db.query('expenses');
    return rows.map((r) => Expense.fromMap({
      'id': r['id'],
      'title': r['title'],
      'amount': r['amount'],
      'date': r['date'],
      'buyerId': r['buyerId'],
      'cycleId': r['cycleId'],
    })).toList();
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final db = await instance;
    await db.delete('expenses');
    for (final e in expenses) {
      await db.insert('expenses', {
        'id': e.id, 'title': e.title, 'amount': e.amount,
        'date': e.date.toIso8601String(), 'buyerId': e.buyerId, 'cycleId': e.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertExpense(Expense expense) async {
    final db = await instance;
    await db.insert('expenses', {
      'id': expense.id, 'title': expense.title, 'amount': expense.amount,
      'date': expense.date.toIso8601String(), 'buyerId': expense.buyerId, 'cycleId': expense.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteExpense(String id) async {
    final db = await instance;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Payments ----
  static Future<List<Payment>> getPayments() async {
    final db = await instance;
    final rows = await db.query('payments');
    return rows.map((r) => Payment.fromMap({
      'id': r['id'], 'memberId': r['memberId'], 'amount': r['amount'],
      'date': r['date'], 'cycleId': r['cycleId'],
    })).toList();
  }

  static Future<void> savePayments(List<Payment> payments) async {
    final db = await instance;
    await db.delete('payments');
    for (final p in payments) {
      await db.insert('payments', {
        'id': p.id, 'memberId': p.memberId, 'amount': p.amount,
        'date': p.date.toIso8601String(), 'cycleId': p.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertPayment(Payment payment) async {
    final db = await instance;
    await db.insert('payments', {
      'id': payment.id, 'memberId': payment.memberId, 'amount': payment.amount,
      'date': payment.date.toIso8601String(), 'cycleId': payment.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deletePayment(String id) async {
    final db = await instance;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Shop Due Items ----
  static Future<List<ShopDueItem>> getShopDueItems() async {
    final db = await instance;
    final rows = await db.query('shop_due_items');
    return rows.map((r) => ShopDueItem.fromMap({
      'id': r['id'], 'title': r['title'], 'amount': r['amount'],
      'date': r['date'], 'buyerId': r['buyerId'], 'cycleId': r['cycleId'],
    })).toList();
  }

  static Future<void> saveShopDueItems(List<ShopDueItem> items) async {
    final db = await instance;
    await db.delete('shop_due_items');
    for (final s in items) {
      await db.insert('shop_due_items', {
        'id': s.id, 'title': s.title, 'amount': s.amount,
        'date': s.date.toIso8601String(), 'buyerId': s.buyerId, 'cycleId': s.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertShopDueItem(ShopDueItem item) async {
    final db = await instance;
    await db.insert('shop_due_items', {
      'id': item.id, 'title': item.title, 'amount': item.amount,
      'date': item.date.toIso8601String(), 'buyerId': item.buyerId, 'cycleId': item.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteShopDueItem(String id) async {
    final db = await instance;
    await db.delete('shop_due_items', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Fried Fine Items ----
  static Future<List<FriedFineItem>> getFriedFineItems() async {
    final db = await instance;
    final rows = await db.query('fried_fine_items');
    return rows.map((r) => FriedFineItem.fromMap({
      'id': r['id'], 'memberId': r['memberId'], 'amount': r['amount'],
      'date': r['date'], 'cycleId': r['cycleId'],
    })).toList();
  }

  static Future<void> saveFriedFineItems(List<FriedFineItem> items) async {
    final db = await instance;
    await db.delete('fried_fine_items');
    for (final f in items) {
      await db.insert('fried_fine_items', {
        'id': f.id, 'memberId': f.memberId, 'amount': f.amount,
        'date': f.date.toIso8601String(), 'cycleId': f.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertFriedFineItem(FriedFineItem item) async {
    final db = await instance;
    await db.insert('fried_fine_items', {
      'id': item.id, 'memberId': item.memberId, 'amount': item.amount,
      'date': item.date.toIso8601String(), 'cycleId': item.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteFriedFineItem(String id) async {
    final db = await instance;
    await db.delete('fried_fine_items', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Guest Meals ----
  static Future<List<GuestMeal>> getGuestMeals() async {
    final db = await instance;
    final rows = await db.query('guest_meals');
    return rows.map((r) => GuestMeal.fromMap({
      'id': r['id'],
      'memberId': r['memberId'],
      'dateString': r['dateString'],
      'count': r['count'],
      'cycleId': r['cycleId'],
    })).toList();
  }

  static Future<void> saveGuestMeals(List<GuestMeal> items) async {
    final db = await instance;
    await db.delete('guest_meals');
    for (final g in items) {
      await db.insert('guest_meals', {
        'id': g.id,
        'memberId': g.memberId,
        'dateString': g.dateString,
        'count': g.count,
        'cycleId': g.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertGuestMeal(GuestMeal item) async {
    final db = await instance;
    await db.insert('guest_meals', {
      'id': item.id,
      'memberId': item.memberId,
      'dateString': item.dateString,
      'count': item.count,
      'cycleId': item.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteGuestMeal(String id) async {
    final db = await instance;
    await db.delete('guest_meals', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Daily Meals ----
  static Future<List<DailyMeal>> getDailyMeals() async {
    final db = await instance;
    final rows = await db.query('daily_meals');
    return rows.map((r) => DailyMeal.fromMap({
      'id': r['id'], 'memberId': r['memberId'], 'dateString': r['dateString'],
      'breakfast': (r['breakfast'] as int) == 1,
      'lunch': (r['lunch'] as int) == 1,
      'dinner': (r['dinner'] as int) == 1,
      'cycleId': r['cycleId'],
    })).toList();
  }

  static Future<void> saveDailyMeals(List<DailyMeal> meals) async {
    final db = await instance;
    await db.delete('daily_meals');
    for (final dm in meals) {
      await db.insert('daily_meals', {
        'id': dm.id, 'memberId': dm.memberId, 'dateString': dm.dateString,
        'breakfast': dm.breakfast ? 1 : 0, 'lunch': dm.lunch ? 1 : 0,
        'dinner': dm.dinner ? 1 : 0, 'cycleId': dm.cycleId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> insertDailyMeal(DailyMeal meal) async {
    final db = await instance;
    await db.insert('daily_meals', {
      'id': meal.id, 'memberId': meal.memberId, 'dateString': meal.dateString,
      'breakfast': meal.breakfast ? 1 : 0, 'lunch': meal.lunch ? 1 : 0,
      'dinner': meal.dinner ? 1 : 0, 'cycleId': meal.cycleId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteDailyMeal(String id) async {
    final db = await instance;
    await db.delete('daily_meals', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Bulk save all (replace) ----
  static Future<void> saveAll({
    required List<BillingCycle> billingCycles,
    required List<Member> members,
    required List<Expense> expenses,
    required List<Payment> payments,
    required List<ShopDueItem> shopDueItems,
    required List<FriedFineItem> friedFineItems,
    List<GuestMeal>? guestMeals,
    required List<DailyMeal> dailyMeals,
    String? activeCycleId,
  }) async {
    final db = await instance;
    await db.transaction((txn) async {
      await txn.delete('billing_cycles');
      for (final c in billingCycles) {
        await txn.insert('billing_cycles', _billingCycleToRow(c));
      }

      await txn.delete('members');
      for (final m in members) {
        await txn.insert('members', {
          'id': m.id, 'name': m.name, 'email': m.email, 'imageUrl': m.imageUrl,
          'isActive': m.isActive ? 1 : 0, 'isActiveToday': m.isActiveToday ? 1 : 0,
          'totalMeals': m.totalMeals, 'payments': m.payments,
          'individualExpenses': m.individualExpenses, 'friedFine': m.friedFine,
          'phone': m.phone, 'roomNumber': m.roomNumber, 'cycleId': m.cycleId,
        });
      }

      await txn.delete('expenses');
      for (final e in expenses) {
        await txn.insert('expenses', {
          'id': e.id, 'title': e.title, 'amount': e.amount,
          'date': e.date.toIso8601String(), 'buyerId': e.buyerId, 'cycleId': e.cycleId,
        });
      }

      await txn.delete('payments');
      for (final p in payments) {
        await txn.insert('payments', {
          'id': p.id, 'memberId': p.memberId, 'amount': p.amount,
          'date': p.date.toIso8601String(), 'cycleId': p.cycleId,
        });
      }

      await txn.delete('shop_due_items');
      for (final s in shopDueItems) {
        await txn.insert('shop_due_items', {
          'id': s.id, 'title': s.title, 'amount': s.amount,
          'date': s.date.toIso8601String(), 'buyerId': s.buyerId, 'cycleId': s.cycleId,
        });
      }

      await txn.delete('fried_fine_items');
      for (final f in friedFineItems) {
        await txn.insert('fried_fine_items', {
          'id': f.id, 'memberId': f.memberId, 'amount': f.amount,
          'date': f.date.toIso8601String(), 'cycleId': f.cycleId,
        });
      }

      await txn.delete('guest_meals');
      if (guestMeals != null) {
        for (final g in guestMeals) {
          await txn.insert('guest_meals', {
            'id': g.id,
            'memberId': g.memberId,
            'dateString': g.dateString,
            'count': g.count,
            'cycleId': g.cycleId,
          });
        }
      }

      await txn.delete('daily_meals');
      for (final dm in dailyMeals) {
        await txn.insert('daily_meals', {
          'id': dm.id, 'memberId': dm.memberId, 'dateString': dm.dateString,
          'breakfast': dm.breakfast ? 1 : 0, 'lunch': dm.lunch ? 1 : 0,
          'dinner': dm.dinner ? 1 : 0, 'cycleId': dm.cycleId,
        });
      }

      if (activeCycleId != null) {
        await txn.insert('app_state',
          {'key': 'active_cycle_id', 'value': activeCycleId},
          conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // ---- Active cycle ID ----
  static Future<String> getActiveCycleId() async {
    final val = await getState('active_cycle_id');
    return val ?? 'cycle_1';
  }

  static Future<void> setActiveCycleId(String id) async {
    await setState('active_cycle_id', id);
  }

  // ---- Remove all data (for logout) ----
  static Future<void> clearAllData() async {
    final db = await instance;
    await db.transaction((txn) async {
      await txn.delete('billing_cycles');
      await txn.delete('members');
      await txn.delete('expenses');
      await txn.delete('payments');
      await txn.delete('shop_due_items');
      await txn.delete('fried_fine_items');
      await txn.delete('guest_meals');
      await txn.delete('daily_meals');
    });
  }
}

