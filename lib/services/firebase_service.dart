import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/mess_data.dart';
import 'google_sign_in_desktop.dart';

class FirebaseService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool isInitialized = false;

  String get userId => _auth.currentUser?.uid ?? '';
  auth.User? get currentUser => _auth.currentUser;

  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<auth.User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      await saveUserToFirestore(result.user!).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Failed to save user to Firestore during sign-in: $e');
    }
    return result.user;
  }

  Future<auth.User?> signUpWithEmail(String email, String password, String name) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      await result.user!.updateDisplayName(name);
    } catch (_) {}
    try {
      await saveUserToFirestore(result.user!).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Failed to save user to Firestore during sign-up: $e');
    }
    return result.user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignInDesktop.disconnect();
    await _auth.signOut();
  }

  Future<void> saveUserToFirestore(auth.User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  DocumentReference get _userDoc =>
      _firestore.collection('users').doc(userId);

  CollectionReference _dataCollection(String name) =>
      _userDoc.collection(name);

  Future<void> saveMember(Member member) async {
    await _dataCollection('members').doc(member.id).set(member.toMap());
  }

  Future<void> deleteMemberDoc(String id) async {
    await _dataCollection('members').doc(id).delete();
  }

  Future<List<Member>> getMembers() async {
    final snapshot = await _dataCollection('members').get();
    return snapshot.docs
        .map((doc) => Member.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get membersStream =>
      _dataCollection('members').snapshots();

  Future<void> saveExpense(Expense expense) async {
    await _dataCollection('expenses').doc(expense.id).set(expense.toMap());
  }

  Future<void> deleteExpenseDoc(String id) async {
    await _dataCollection('expenses').doc(id).delete();
  }

  Future<List<Expense>> getExpenses() async {
    final snapshot = await _dataCollection('expenses').get();
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get expensesStream =>
      _dataCollection('expenses').snapshots();

  Future<void> savePayment(Payment payment) async {
    await _dataCollection('payments').doc(payment.id).set(payment.toMap());
  }

  Future<void> deletePaymentDoc(String id) async {
    await _dataCollection('payments').doc(id).delete();
  }

  Future<List<Payment>> getPayments() async {
    final snapshot = await _dataCollection('payments').get();
    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get paymentsStream =>
      _dataCollection('payments').snapshots();

  Stream<QuerySnapshot> get shopDueItemsStream =>
      _dataCollection('shop_due').snapshots();

  Future<void> saveShopDueItem(ShopDueItem item) async {
    await _dataCollection('shop_due').doc(item.id).set(item.toMap());
  }

  Future<void> deleteShopDueItemDoc(String id) async {
    await _dataCollection('shop_due').doc(id).delete();
  }

  Future<List<ShopDueItem>> getShopDueItems() async {
    final snapshot = await _dataCollection('shop_due').get();
    return snapshot.docs
        .map((doc) => ShopDueItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get guestMealsStream =>
      _dataCollection('guest_meals').snapshots();

  Future<void> saveGuestMeal(GuestMeal item) async {
    await _dataCollection('guest_meals').doc(item.id).set(item.toMap());
  }

  Future<void> deleteGuestMealDoc(String id) async {
    await _dataCollection('guest_meals').doc(id).delete();
  }

  Future<List<GuestMeal>> getGuestMeals() async {
    final snapshot = await _dataCollection('guest_meals').get();
    return snapshot.docs
        .map((doc) => GuestMeal.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get friedFineItemsStream =>
      _dataCollection('fried_fine').snapshots();

  Future<void> saveFriedFineItem(FriedFineItem item) async {
    await _dataCollection('fried_fine').doc(item.id).set(item.toMap());
  }

  Future<void> deleteFriedFineItemDoc(String id) async {
    await _dataCollection('fried_fine').doc(id).delete();
  }

  Future<List<FriedFineItem>> getFriedFineItems() async {
    final snapshot = await _dataCollection('fried_fine').get();
    return snapshot.docs
        .map((doc) => FriedFineItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDailyMeal(DailyMeal meal) async {
    await _dataCollection('daily_meals').doc(meal.id).set(meal.toMap());
  }

  Future<void> deleteDailyMealDoc(String id) async {
    await _dataCollection('daily_meals').doc(id).delete();
  }

  Future<List<DailyMeal>> getDailyMeals() async {
    final snapshot = await _dataCollection('daily_meals').get();
    return snapshot.docs
        .map((doc) => DailyMeal.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get dailyMealsStream =>
      _dataCollection('daily_meals').snapshots();

  Future<void> saveBillingCycle(BillingCycle cycle) async {
    await _dataCollection('cycles').doc(cycle.id).set(cycle.toMap());
  }

  Future<List<BillingCycle>> getBillingCycles() async {
    final snapshot = await _dataCollection('cycles').get();
    return snapshot.docs
        .map((doc) => BillingCycle.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> get billingCyclesStream =>
      _dataCollection('cycles').snapshots();

  Future<void> deleteCycleDoc(String id) async {
    await _dataCollection('cycles').doc(id).delete();
  }

  Future<void> saveDataBatch({
    List<Member>? members,
    List<Expense>? expenses,
    List<Payment>? payments,
    List<ShopDueItem>? shopDueItems,
    List<FriedFineItem>? friedFineItems,
    List<DailyMeal>? dailyMeals,
    List<GuestMeal>? guestMeals,
    List<BillingCycle>? cycles,
  }) async {
    final batch = _firestore.batch();
    final baseRef = _userDoc;

    void setData(String subCol, String docId, Map<String, dynamic> data) {
      batch.set(baseRef.collection(subCol).doc(docId), data, SetOptions(merge: true));
    }

    members?.forEach((m) => setData('members', m.id, m.toMap()));
    expenses?.forEach((e) => setData('expenses', e.id, e.toMap()));
    payments?.forEach((p) => setData('payments', p.id, p.toMap()));
    shopDueItems?.forEach((s) => setData('shop_due', s.id, s.toMap()));
    friedFineItems?.forEach((f) => setData('fried_fine', f.id, f.toMap()));
    dailyMeals?.forEach((d) => setData('daily_meals', d.id, d.toMap()));
    guestMeals?.forEach((g) => setData('guest_meals', g.id, g.toMap()));
    cycles?.forEach((c) => setData('cycles', c.id, c.toMap()));

    await batch.commit();
  }
}

