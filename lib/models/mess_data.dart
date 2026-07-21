class BillingCycle {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  BillingCycle({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  BillingCycle copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return BillingCycle(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory BillingCycle.fromMap(Map<String, dynamic> map) {
    return BillingCycle(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isActive: map['isActive'] ?? true,
    );
  }
}

class Member {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final bool isActive;
  final bool isActiveToday;
  final double totalMeals;
  final double guestMeals;
  final double payments;
  final double individualExpenses;
  final double friedFine;
  final String phone;
  final String roomNumber;
  final String cycleId;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    this.isActive = true,
    this.isActiveToday = true,
    this.totalMeals = 0.0,
    this.guestMeals = 0.0,
    this.payments = 0.0,
    this.individualExpenses = 0.0,
    this.friedFine = 0.0,
    this.phone = '',
    this.roomNumber = '',
    this.cycleId = '',
  });

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    bool? isActive,
    bool? isActiveToday,
    double? totalMeals,
    double? guestMeals,
    double? payments,
    double? individualExpenses,
    double? friedFine,
    String? phone,
    String? roomNumber,
    String? cycleId,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isActiveToday: isActiveToday ?? this.isActiveToday,
      totalMeals: totalMeals ?? this.totalMeals,
      guestMeals: guestMeals ?? this.guestMeals,
      payments: payments ?? this.payments,
      individualExpenses: individualExpenses ?? this.individualExpenses,
      friedFine: friedFine ?? this.friedFine,
      phone: phone ?? this.phone,
      roomNumber: roomNumber ?? this.roomNumber,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isActiveToday': isActiveToday,
      'totalMeals': totalMeals,
      'guestMeals': guestMeals,
      'payments': payments,
      'individualExpenses': individualExpenses,
      'friedFine': friedFine,
      'phone': phone,
      'roomNumber': roomNumber,
      'cycleId': cycleId,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      isActiveToday: map['isActiveToday'] ?? true,
      totalMeals: (map['totalMeals'] ?? 0.0).toDouble(),
      guestMeals: (map['guestMeals'] ?? 0.0).toDouble(),
      payments: (map['payments'] ?? 0.0).toDouble(),
      individualExpenses: (map['individualExpenses'] ?? 0.0).toDouble(),
      friedFine: (map['friedFine'] ?? 0.0).toDouble(),
      phone: map['phone'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      cycleId: map['cycleId'] ?? '',
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String buyerId;
  final String cycleId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.buyerId,
    this.cycleId = '',
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? buyerId,
    String? cycleId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      buyerId: buyerId ?? this.buyerId,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'buyerId': buyerId,
      'cycleId': cycleId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      buyerId: map['buyerId'] ?? '',
      cycleId: map['cycleId'] ?? '',
    );
  }
}

class Payment {
  final String id;
  final String memberId;
  final double amount;
  final DateTime date;
  final String cycleId;

  Payment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.date,
    this.cycleId = '',
  });

  Payment copyWith({
    String? id,
    String? memberId,
    double? amount,
    DateTime? date,
    String? cycleId,
  }) {
    return Payment(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'date': date.toIso8601String(),
      'cycleId': cycleId,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      cycleId: map['cycleId'] ?? '',
    );
  }
}

class ShopDueItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String buyerId;
  final String cycleId;

  ShopDueItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.buyerId,
    this.cycleId = '',
  });

  ShopDueItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? buyerId,
    String? cycleId,
  }) {
    return ShopDueItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      buyerId: buyerId ?? this.buyerId,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'buyerId': buyerId,
      'cycleId': cycleId,
    };
  }

  factory ShopDueItem.fromMap(Map<String, dynamic> map) {
    return ShopDueItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      buyerId: map['buyerId'] ?? '',
      cycleId: map['cycleId'] ?? '',
    );
  }
}

class FriedFineItem {
  final String id;
  final String memberId;
  final double amount;
  final DateTime date;
  final String cycleId;

  FriedFineItem({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.date,
    this.cycleId = '',
  });

  FriedFineItem copyWith({
    String? id,
    String? memberId,
    double? amount,
    DateTime? date,
    String? cycleId,
  }) {
    return FriedFineItem(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'date': date.toIso8601String(),
      'cycleId': cycleId,
    };
  }

  factory FriedFineItem.fromMap(Map<String, dynamic> map) {
    return FriedFineItem(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      cycleId: map['cycleId'] ?? '',
    );
  }
}

class GuestMeal {
  final String id;
  final String memberId;
  final String dateString;
  final int count;
  final String cycleId;

  GuestMeal({
    required this.id,
    required this.memberId,
    required this.dateString,
    this.count = 1,
    this.cycleId = '',
  });

  GuestMeal copyWith({
    String? id,
    String? memberId,
    String? dateString,
    int? count,
    String? cycleId,
  }) {
    return GuestMeal(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      dateString: dateString ?? this.dateString,
      count: count ?? this.count,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'dateString': dateString,
      'count': count,
      'cycleId': cycleId,
    };
  }

  factory GuestMeal.fromMap(Map<String, dynamic> map) {
    return GuestMeal(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      dateString: map['dateString'] ?? '',
      count: (map['count'] ?? 0),
      cycleId: map['cycleId'] ?? '',
    );
  }
}

class DailyMeal {
  final String id;
  final String memberId;
  final String dateString;
  final bool breakfast;
  final bool lunch;
  final bool dinner;
  final String cycleId;

  DailyMeal({
    required this.id,
    required this.memberId,
    required this.dateString,
    this.breakfast = false,
    this.lunch = false,
    this.dinner = false,
    this.cycleId = '',
  });

  DailyMeal copyWith({
    String? id,
    String? memberId,
    String? dateString,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
    String? cycleId,
  }) {
    return DailyMeal(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      dateString: dateString ?? this.dateString,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      cycleId: cycleId ?? this.cycleId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'dateString': dateString,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'cycleId': cycleId,
    };
  }

  factory DailyMeal.fromMap(Map<String, dynamic> map) {
    return DailyMeal(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      dateString: map['dateString'] ?? '',
      breakfast: map['breakfast'] ?? false,
      lunch: map['lunch'] ?? false,
      dinner: map['dinner'] ?? false,
      cycleId: map['cycleId'] ?? '',
    );
  }
}

