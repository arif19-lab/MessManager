import 'package:flutter/material.dart';

class BanglaLocalizations {
  final Locale locale;

  BanglaLocalizations(this.locale);

  static BanglaLocalizations of(BuildContext context) {
    return Localizations.of<BanglaLocalizations>(context, BanglaLocalizations)!;
  }

  bool get isBangla => locale.languageCode == 'bn';

  // ─── General / Common ───
  String get language => isBangla ? 'ভাষা' : 'Language';
  String get settings => isBangla ? 'সেটিংস' : 'Settings';
  String get customizeHome => isBangla ? 'কাস্টমাইজ' : 'Customize';
  String get closeMeal => isBangla ? 'মিল বন্ধ করুন' : 'Close Meal';
  String get pdf => isBangla ? 'পিডিএফ' : 'PDF';
  String get save => isBangla ? 'সংরক্ষণ' : 'Save';
  String get cancel => isBangla ? 'বাতিল' : 'Cancel';
  String get delete => isBangla ? 'মুছুন' : 'Delete';
  String get clearAll => isBangla ? 'সব মুছুন' : 'Clear All';
  String get add => isBangla ? 'যোগ করুন' : 'Add';
  String get remove => isBangla ? 'সরান' : 'Remove';
  String get total => isBangla ? 'মোট' : 'Total';
  String get selectMember => isBangla ? 'সদস্য নির্বাচন করুন' : 'Select Member';
  String get selectDate => isBangla ? 'তারিখ নির্বাচন করুন' : 'Select Date';
  String get msgNoMembersYet => isBangla ? 'এখনো কোনো সদস্য নেই' : 'No members yet';

  // ─── Navigation ───
  String get navHome => isBangla ? 'হোম' : 'Home';
  String get navDashboard => isBangla ? 'ড্যাশবোর্ড' : 'Dashboard';
  String get navMeals => isBangla ? 'মিল' : 'Meals';
  String get navPeople => isBangla ? 'সদস্য' : 'People';
  String get navExpenses => isBangla ? 'খরচ' : 'Expenses';
  String get navPayments => isBangla ? 'পেমেন্ট' : 'Payments';
  String get navFeastFines => isBangla ? 'ভোজ ও জরিমানা' : 'Feast & Fines';
  String get navSummary => isBangla ? 'সারসংক্ষেপ' : 'Summary';
  String get navNotifications => isBangla ? 'নোটিফিকেশন' : 'Notifications';
  String get navSettings => isBangla ? 'সেটিংস' : 'Settings';

  // ─── App Bar ───
  String get appTitle => 'Mess Manager';
  String get greetingMorning => 'Good morning';
  String get greetingAfternoon => 'Good afternoon';
  String get greetingEvening => 'Good evening';
  String get greetingNight => 'Good night';
  String get controlPanel => isBangla ? 'কন্ট্রোল প্যানেল' : 'CONTROL PANEL';
  String get homeCustomizedSuccess => isBangla ? 'হোম ড্যাশবোর্ড সফলভাবে কাস্টমাইজ করা হয়েছে!' : 'Home dashboard customized successfully!';

  // ─── Desktop Tab Labels ───
  String get tabDashboard => isBangla ? 'ড্যাশবোর্ড' : 'Dashboard';
  String get tabMeals => isBangla ? 'মিল' : 'Meals';
  String get tabPeople => isBangla ? 'সদস্য' : 'People';
  String get tabExpenses => isBangla ? 'খরচ' : 'Expenses';
  String get tabPayments => isBangla ? 'পেমেন্ট' : 'Payments';
  String get tabFeastFines => isBangla ? 'ভোজ ও জরিমানা' : 'Feast & Fines';

  // ─── Settings Panel (Desktop) ───
  String get appearance => isBangla ? 'চেহারা' : 'Appearance';
  String get light => isBangla ? 'লাইট' : 'Light';
  String get dark => isBangla ? 'ডার্ক' : 'Dark';
  String get reports => isBangla ? 'রিপোর্ট' : 'Reports';
  String get notifications => isBangla ? 'নোটিফিকেশন' : 'Notifications';

  // ─── Summary Screen ───
  String get closeActiveMeal => isBangla ? 'সক্রিয় মিল বন্ধ করবেন?' : 'Close Active Meal?';
  String get mealName => isBangla ? 'মিলের নাম' : 'Meal Name';
  String get mealNameHint => isBangla ? 'যেমন: জুন ১ - জুলাই ৪' : 'e.g. June 1 - July 4';
  String get closeMealConfirm => isBangla ? 'এটি সব হিসাব স্থায়ীভাবে লক করবে এবং নতুন মিল শুরু করবে।' : 'This will lock all calculations for this meal permanently and start a fresh meal.';
  String get mealClosedSuccess => isBangla ? 'মিল সফলভাবে বন্ধ করা হয়েছে! নতুন মিল শুরু হয়েছে।' : 'Meal closed successfully! Started next meal.';
  String get billingCycles => isBangla ? 'বিলিং সাইকেল' : 'Billing Cycles';
  String get billingCyclesDesc => isBangla ? 'একটি সাইকেল নির্বাচন করুন তার রিপোর্ট দেখতে' : 'Select a cycle to view and edit its accounting reports';
  String get active => isBangla ? 'সক্রিয়' : 'ACTIVE';
  String get settled => isBangla ? 'নিষ্পত্তি' : 'Settled';

  // Monthly Summary Table
  String get monthlySummaryTitle => isBangla ? 'মাসিক সারাংশ (মেস ম্যানেজার)' : 'Monthly Summary Sheet (By Mess Manager)';
  String get colMemberName => isBangla ? 'সদস্যের নাম' : 'Member Name';
  String get colMember => isBangla ? 'সদস্য' : 'Member';
  String get colMeals => isBangla ? 'মিল' : 'Meals';
  String get colBill => isBangla ? 'বিল' : 'Bill';
  String get colPaid => isBangla ? 'পরিশোধিত' : 'Paid';
  String get colBalance => isBangla ? 'ব্যালেন্স' : 'Balance';
  String get colGuestMeals => isBangla ? 'অতিথি মিল' : 'Guest Meals';
  String get colGuestCost => isBangla ? 'অতিথি খরচ' : 'Guest Cost';
  String get colMealRate => isBangla ? 'মিল রেট' : 'Meal Rate';
  String get colCost => isBangla ? 'খরচ' : 'Cost';
  String get colRate => isBangla ? 'রেট' : 'Rate';
  String get colGuests => isBangla ? 'অতিথি' : 'Guests';

  // Balance labels
  String get pay => isBangla ? 'পরিশোধ' : 'Pay';
  String get due => isBangla ? 'বাকি' : 'Due';

  // Guest Meals Report
  String get guestMealsReport => isBangla ? 'অতিথি মিল রিপোর্ট' : 'Guest Meals Report';
  String get guestMealsDesc => isBangla ? 'প্রতি সদস্যের অতিথি মিল এবং বর্তমান মিল রেটে অতিরিক্ত খরচ' : 'Total guest meals per member and the additional cost charged at the current meal rate.';
  String get noGuestMealsYet => isBangla ? 'এখনো কোনো অতিথি মিল নেই' : 'No guest meals recorded yet';
  String get goToGuestMeals => isBangla ? 'অতিথি মিল যোগ করতে মিল স্ক্রিনে যান' : 'Go to Meals screen → Guest Meal to add';
  String get guestLabelFormat => isBangla ? 'অতিথি =' : 'Guest =';
  String get guestTotal => isBangla ? 'মোট' : 'TOTAL';

  // Summary Cards
  String get mealRate => isBangla ? 'মিল রেট' : 'Meal Rate';
  String get totalMeals => isBangla ? 'মোট মিল' : 'Total Meals';
  String get totalPayments => isBangla ? 'মোট পেমেন্ট' : 'Total Payments';
  String get totalCost => isBangla ? 'মোট খরচ' : 'Total Cost';
  String get receivables => isBangla ? 'প্রাপ্য' : 'Receivables';
  String get payables => isBangla ? 'পরিশোধ্য' : 'Payables';

  // ─── Expenses Screen ───
  String get shopDueRecords => isBangla ? 'দোকানের বাকি রেকর্ড' : 'Shop Due Records';
  String get messExpenses => isBangla ? 'মেসের খরচ' : 'Mess Expenses';
  String get shopDueDesc => isBangla ? 'দোকানের বাকি, পেমেন্ট এবং বকেয়া আইটেম ম্যানেজ করুন' : 'Manage shop dues, payments, and individual outstanding items';
  String get expensesDesc => isBangla ? 'সব দৈনিক বাজার এবং মেসের খরচ ট্র্যাক করুন' : 'Track all daily bazaar and mess cost items';
  String get backExpenses => isBangla ? 'পিছনে যান' : 'Back Expenses';
  String get addShopDue => isBangla ? 'দোকানের বাকি যোগ করুন' : 'Add Shop Due';
  String get addAmount => isBangla ? 'পরিমাণ যোগ করুন' : 'Add Amount';
  String get addExpense => isBangla ? 'খরচ যোগ করুন' : 'Add Expense';
  String get noExpensesYet => isBangla ? 'এখনো কোনো খরচ নেই' : 'No expense records yet';
  String get noShopDuesYet => isBangla ? 'এখনো কোনো দোকানের বাকি নেই' : 'No shop dues yet';
  String get addExpenseItem => isBangla ? 'খরচের আইটেম যোগ করুন' : 'Add Expense Item';
  String get expenseTitle => isBangla ? 'খরচের শিরোনাম (যেমন: বাজার)' : 'Expense Title (e.g. Bazar)';
  String get amountBDT => isBangla ? 'পরিমাণ (টাকা)' : 'Amount (BDT)';
  String get selectBuyer => isBangla ? 'ক্রেতা নির্বাচন করুন' : 'Select Buyer';
  String get editExpense => isBangla ? 'খরচের বিবরণ সম্পাদনা করুন' : 'Edit Expense details';
  String get deleteExpense => isBangla ? 'খরচ মুছুন' : 'Delete Expense';
  String get addShopDueRecord => isBangla ? 'দোকানের বাকি রেকর্ড যোগ করুন' : 'Add Shop Due Record';
  String get dueItemTitle => isBangla ? 'বাকি আইটেম (যেমন: চাল)' : 'Due Item (e.g. চাল)';
  String get editShopDue => isBangla ? 'দোকানের বাকি বিবরণ সম্পাদনা করুন' : 'Edit Shop Due details';
  String get deleteShopDue => isBangla ? 'দোকানের বাকি মুছুন' : 'Delete Shop Due';
  String get selectMember2 => isBangla ? 'সদস্য নির্বাচন করুন' : 'Select Member';

  // ─── Payments Screen ───
  String get messPayments => isBangla ? 'মেসের পেমেন্ট' : 'Mess Payments';
  String get paymentsDesc => isBangla ? 'সদস্যদের পেমেন্ট এবং অগ্রিম জমা ট্র্যাক করুন' : 'Track member payments and advance deposits';
  String get addPayment => isBangla ? 'পেমেন্ট যোগ করুন' : 'Add Payment';
  String get noPaymentsYet => isBangla ? 'এখনো কোনো পেমেন্ট নেই' : 'No payments recorded yet';
  String get addPaymentRecord => isBangla ? 'পেমেন্ট রেকর্ড যোগ করুন' : 'Add Payment Record';
  String get paymentAmount => isBangla ? 'পেমেন্টের পরিমাণ (টাকা)' : 'Payment Amount (BDT)';
  String get editPayment => isBangla ? 'পেমেন্টের বিবরণ সম্পাদনা করুন' : 'Edit Payment Details';
  String get deletePayment => isBangla ? 'পেমেন্ট মুছুন' : 'Delete Payment';
  String get paymentDeleteConfirm => isBangla ? 'আপনি কি নিশ্চিত এই পেমেন্ট রেকর্ড মুছতে চান?' : 'Are you sure you want to delete this payment record?';

  // ─── People Screen ───
  String get membersDirectory => isBangla ? 'সদস্য ডিরেক্টরি' : 'Members Directory';
  String get membersDesc => isBangla ? 'মেসের সদস্য, রুম নাম্বার এবং যোগাযোগের তথ্য ম্যানেজ করুন' : 'Manage mess members, room numbers, and contact details';
  String get membersList => isBangla ? 'সদস্য তালিকা' : 'Members List';
  String get addMember => isBangla ? 'সদস্য যোগ করুন' : 'Add Member';
  String get addNewMember => isBangla ? 'নতুন সদস্য যোগ করুন' : 'Add New Member';
  String get fullName => isBangla ? 'পুরো নাম' : 'Full Name';
  String get emailAddress => isBangla ? 'ইমেইল ঠিকানা' : 'Email Address';
  String get phoneNumber => isBangla ? 'ফোন নম্বর' : 'Phone Number';
  String get roomSeatNumber => isBangla ? 'রুম / সিট নম্বর' : 'Room / Seat Number';
  String get editMember => isBangla ? 'সদস্যের বিবরণ সম্পাদনা করুন' : 'Edit Member Details';
  String get deleteMember => isBangla ? 'সদস্য মুছুন' : 'Delete Member';
  String get deleteMemberConfirm => isBangla ? 'আপনি কি নিশ্চিত %s কে ডিরেক্টরি থেকে মুছতে চান?' : 'Are you sure you want to delete %s from the mess directory?';

  // ─── Meals Screen ───
  String get dailyMealsTracker => isBangla ? 'দৈনিক মিল ট্র্যাকার' : 'Daily Meals Tracker';
  String get mealsDesc => isBangla ? 'সব মেস সদস্যের দৈনিক সক্রিয় মিল ট্র্যাক এবং মার্ক করুন' : 'Track and mark daily active meals for all mess members';
  String get eatingActiveToday => isBangla ? 'আজ খাচ্ছে / সক্রিয়' : 'Eating / Active Today';
  String get totalMealsToday => isBangla ? 'আজকের মোট মিল' : 'Total Meals Today';
  String get unmarkAll => isBangla ? 'সব আনমার্ক' : 'Unmark All';
  String get markAll => isBangla ? 'সব মার্ক' : 'Mark All';
  String get markedSuccess => isBangla ? 'সব মিল সফলভাবে মার্ক করা হয়েছে!' : 'Marked all meals successfully!';
  String get unmarkedSuccess => isBangla ? 'সব মিল সফলভাবে আনমার্ক করা হয়েছে!' : 'Unmarked all meals successfully!';
  String get activeMembersList => isBangla ? 'সক্রিয় সদস্য তালিকা' : 'Active Members List';
  String get all => isBangla ? 'সব' : 'All';
  String get breakfastLabel => isBangla ? 'নাস্তা' : 'B';
  String get lunchLabel => isBangla ? 'দুপুর' : 'L';
  String get dinnerLabel => isBangla ? 'রাত' : 'D';
  String get select => isBangla ? 'নির্বাচন' : 'Select';

  // Month names for date picker
  String get january => isBangla ? 'জানুয়ারি' : 'January';
  String get february => isBangla ? 'ফেব্রুয়ারি' : 'February';
  String get march => isBangla ? 'মার্চ' : 'March';
  String get april => isBangla ? 'এপ্রিল' : 'April';
  String get may => isBangla ? 'মে' : 'May';
  String get june => isBangla ? 'জুন' : 'June';
  String get july => isBangla ? 'জুলাই' : 'July';
  String get august => isBangla ? 'আগস্ট' : 'August';
  String get september => isBangla ? 'সেপ্টেম্বর' : 'September';
  String get october => isBangla ? 'অক্টোবর' : 'October';
  String get november => isBangla ? 'নভেম্বর' : 'November';
  String get december => isBangla ? 'ডিসেম্বর' : 'December';

  // Week days
  String get sun => isBangla ? 'রবি' : 'Su';
  String get mon => isBangla ? 'সোম' : 'Mo';
  String get tue => isBangla ? 'মঙ্গল' : 'Tu';
  String get wed => isBangla ? 'বুধ' : 'We';
  String get thu => isBangla ? 'বৃহস্পতি' : 'Th';
  String get fri => isBangla ? 'শুক্র' : 'Fr';
  String get sat => isBangla ? 'শনি' : 'Sa';

  // ─── Fried & Fine Screen ───
  String get feastAndFines => isBangla ? 'ভোজ ও জরিমানা' : 'Feast & Fines';
  String get addFine => isBangla ? 'জরিমানা যোগ করুন' : 'Add Fine';
  String get guest => isBangla ? 'অতিথি' : 'Guest';
  String get noRecordsFound => isBangla ? 'কোনো রেকর্ড পাওয়া যায়নি' : 'No records found';
  String get clickAddFine => isBangla ? 'জরিমানা যোগ করতে "Add Fine" বাটনে ক্লিক করুন' : 'Click "Add Fine" to record a fine';
  String get addExtraFineBDT => isBangla ? 'অতিরিক্ত / জরিমানা যোগ করুন' : 'Add Extra / Fine BDT';
  String get amounts => isBangla ? 'পরিমাণসমূহ' : 'Amounts';
  String get clearFines => isBangla ? 'জরিমানা মুছুন' : 'Clear Fines';
  String get clearFinesConfirm => isBangla ? 'আপনি কি নিশ্চিত %s এর সব জরিমানা মুছতে চান?' : 'Are you sure you want to clear all Fried & Fine amounts for %s?';
  String get deleteAmount => isBangla ? 'পরিমাণ মুছুন' : 'Delete Amount';
  String get deleteAmountConfirm => isBangla ? 'আপনি কি নিশ্চিত %s টাকার এই পরিমাণটি মুছতে চান?' : 'Are you sure you want to delete this amount of BDT %s?';

  // ─── Guest Meals Screen ───
  String get guestMealsTitle => isBangla ? 'অতিথি মিল' : 'Guest Meals';
  String get addGuest => isBangla ? 'অতিথি যোগ করুন' : 'Add Guest';
  String get noGuests => isBangla ? 'কোনো অতিথি নেই' : 'No guests';
  String get guestMealRate => isBangla ? 'মিল রেট:' : 'Meal Rate:';
  String get noGuestMeals => isBangla ? 'এখনো কোনো অতিথি মিল নেই' : 'No guest meals yet';
  String get clickAddGuest => isBangla ? '"অতিথি যোগ করুন" বাটনে ক্লিক করুন' : 'Click "Add Guest" to record a guest meal';
  String get addGuestMeal => isBangla ? 'অতিথি মিল যোগ করুন' : 'Add Guest Meal';
  String get guestCount => isBangla ? 'অতিথির সংখ্যা' : 'Guest Count';
  String get clearGuest => isBangla ? 'অতিথি মুছুন' : 'Clear Guest';
  String get clearGuestConfirm => isBangla ? 'আপনি কি %s জন অতিথি এবং %s এর জন্য সরাতে চান?' : 'Are you sure you want to remove %s guest meal(s) for %s?';
  String get clearAllGuests => isBangla ? 'সব অতিথি মুছুন' : 'Clear All Guests';
  String get clearAllGuestsConfirm => isBangla ? 'আপনি কি %s তারিখের সব অতিথি মিল মুছতে চান?' : 'Are you sure you want to clear all guest meals for %s?';

  // ─── Notifications Screen ───
  String get notificationsToggle => isBangla ? 'নোটিফিকেশন টগল' : 'Notifications Toggle';
  String get enableReceivingUpdates => isBangla ? 'আপডেট পেতে সক্রিয় করুন' : 'Enable to receive updates';
  String get reminders => isBangla ? 'রিমাইন্ডার' : 'Reminders';
  String get mealReminder => isBangla ? 'মিল রিমাইন্ডার' : 'Meal Reminder';
  String get expenseTracking => isBangla ? 'খরচ ট্র্যাকিং' : 'Expense Tracking';
  String get paymentAlert => isBangla ? 'পেমেন্ট সতর্কতা' : 'Payment Alert';
  String get setFor => isBangla ? 'সেট করা হয়েছে' : 'Set for';
  String get changeTime => isBangla ? 'সময় পরিবর্তন' : 'Change Time';
  String get customMessage => isBangla ? 'কাস্টম মেসেজ' : 'Custom Message';

  // ─── Settings Screen ───
  String get visualTheme => isBangla ? 'ভিজুয়াল থিম' : 'Visual Theme';
  String get chooseYourStyle => isBangla ? 'আপনার পছন্দের স্টাইল নির্বাচন করুন' : 'Choose your preferred style';
  String get selectLanguage => isBangla ? 'আপনার পছন্দের ভাষা নির্বাচন করুন' : 'Select your preferred language';

  // ─── Customize Home ───
  String get selectCardsToShow => isBangla ? 'ড্যাশবোর্ডে কোন কার্ড দেখাবেন তা নির্বাচন করুন' : 'Select which cards to show on your dashboard';
  String get system => isBangla ? 'সিস্টেম' : 'System';
  String get fullScreenMode => isBangla ? 'ফুল স্ক্রিন মোড' : 'Full Screen Mode';
  String get hideStatusBars => isBangla ? 'স্ট্যাটাস ও নেভিগেশন বার লুকান' : 'Hide status & navigation bars';
  String get dashboardCards => isBangla ? 'ড্যাশবোর্ড কার্ড' : 'Dashboard Cards';
  String get onLabel => isBangla ? 'চালু' : 'On';
  String get offLabel => isBangla ? 'বন্ধ' : 'Off';

  // Dashboard Card Titles
  String get cardMealRate => isBangla ? 'মিল রেট' : 'Meal Rate';
  String get cardActiveMembers => isBangla ? 'সক্রিয় সদস্য' : 'Active Members';
  String get cardMealsToday => isBangla ? 'আজকের মিল' : 'Meals Today';
  String get cardTotalMeals => isBangla ? 'মোট মিল (সাইকেল)' : 'Total Meals (Cycle)';
  String get cardExpenses => isBangla ? 'খরচ (সাইকেল)' : 'Expenses (Cycle)';
  String get cardPayments => isBangla ? 'পেমেন্ট (সাইকেল)' : 'Payments (Cycle)';
  String get cardMealBalance => isBangla ? 'মিল ব্যালেন্স' : 'Meal Balance';
  String get cardShopDue => isBangla ? 'দোকানের বাকি' : 'Shop Due';
  String get cardFeastFines => isBangla ? 'ভোজ ও জরিমানা (মোট)' : 'Feast & Fines (Total)';

  // ─── Drawer ───
  String get drawerMenu => isBangla ? 'মেনু' : 'Menu';
  String get drawerOptions => isBangla ? 'অপশন' : 'Options';
  String get drawerReports => isBangla ? 'রিপোর্ট' : 'Reports';
  String get drawerCustomizeHome => isBangla ? 'হোম কাস্টমাইজ' : 'Customize Home';
  String get drawerNotifications => isBangla ? 'নোটিফিকেশন' : 'Notifications';
  String get drawerExpenses => isBangla ? 'খরচ' : 'Expenses';
  String get drawerPayments => isBangla ? 'পেমেন্ট' : 'Payments';
  String get drawerFeastFines => isBangla ? 'ভোজ ও জরিমানা' : 'Feast & Fines';
  String get versionLabel => isBangla ? 'v১.০.০' : 'v1.0.0';

  // ─── Profile Dialog ───
  String get welcomeBack => isBangla ? 'স্বাগতম' : 'WELCOME';
  String get back => isBangla ? 'ফিরে আসুন' : 'BACK';
  String get admin => isBangla ? 'অ্যাডমিন' : 'ADMIN';
  String get emailAddressLabel => isBangla ? 'ইমেইল ঠিকানা' : 'EMAIL ADDRESS';
  String get close => isBangla ? 'বন্ধ' : 'CLOSE';
  String get logout => isBangla ? 'লগআউট' : 'LOGOUT';
  String get login => isBangla ? 'লগইন' : 'LOGIN';

  // ─── Splash Screen ───
  String get loadingData => isBangla ? 'আপনার ডাটা লোড হচ্ছে...' : 'Loading your data...';

  // ─── Login Screen ───
  String get logIn => isBangla ? 'লগইন' : 'Log in';
  String get signUp => isBangla ? 'সাইন আপ' : 'Sign Up';
  String get password => isBangla ? 'পাসওয়ার্ড' : 'Password';
  String get forgotPassword => isBangla ? 'পাসওয়ার্ড ভুলে গেছেন?' : 'Forgot Password?';
  String get fullNameLabel => isBangla ? 'পুরো নাম' : 'Full Name';
  String get emailLabel => isBangla ? 'ইমেইল' : 'Email';
  String get alreadyHaveAccount => isBangla ? 'ইতিমধ্যে অ্যাকাউন্ট আছে? লগইন করুন' : 'Already have an account? Log in';
  String get noAccountSignUp => isBangla ? 'অ্যাকাউন্ট নেই? সাইন আপ করুন' : "Don't have an account? Sign up";
  String get orLogInWith => isBangla ? 'অথবা লগইন করুন' : 'or log in with';
  String get offlineMode => isBangla ? 'অফলাইন মোড' : 'Offline Mode';
  String get goToApp => isBangla ? 'অ্যাপে যান' : 'Go to App';
  String get resetPassword => isBangla ? 'পাসওয়ার্ড রিসেট' : 'Reset Password';
  String get newPassword => isBangla ? 'নতুন পাসওয়ার্ড' : 'New Password';
  String get confirmPassword => isBangla ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm Password';
  String get reset => isBangla ? 'রিসেট' : 'Reset';
  String get savedEmails => isBangla ? 'সংরক্ষিত ইমেইল' : 'Saved Emails';
  String get tapEmailToFill => isBangla ? 'দ্রুত পূরণ করতে ইমেইলে ট্যাপ করুন' : 'Tap an email to fill it in quickly.';
  String get noSavedAccounts => isBangla ? 'কোনো সংরক্ষিত অ্যাকাউন্ট নেই।' : 'No saved accounts.';
  String get checkYourInbox => isBangla ? 'আপনার ইনবক্স চেক করুন' : 'Check Your Inbox';
  String get passwordResetSent => isBangla ? 'আমরা একটি পাসওয়ার্ড রিসেট ইমেইল পাঠিয়েছি' : 'We sent a password reset email to';
  String get openEmailApp => isBangla ? 'ইমেইল অ্যাপ খুলুন' : 'Open Email App';
  String get resendEmail => isBangla ? 'পুনরায় ইমেইল পাঠান' : 'Resend Email';
  String get doItLater => isBangla ? 'পরে করব' : "I'll do it later";

  // PDF (used in summary_screen.dart PDF section)
  String get generatingPDF => isBangla ? 'পিডিএফ রিপোর্ট তৈরি করা হচ্ছে...' : 'Generating high-quality PDF report...';
  String get pdfFailed => isBangla ? 'পিডিএফ তৈরি করতে ব্যর্থ:' : 'Failed to generate PDF:';
  String get monthlyReportSheet => isBangla ? 'মাসিক রিপোর্ট শীট' : 'MONTHLY REPORT SHEET';
  String get cycleDuration => isBangla ? 'সাইকেল সময়কাল' : 'CYCLE DURATION';
  String get cycleOverviewMetrics => isBangla ? 'সাইকেল ওভারভিউ মেট্রিক্স' : 'CYCLE OVERVIEW METRICS';
  String get monthlySummarySheetPDF => isBangla ? 'মাসিক সারাংশ শীট (মেস ম্যানেজার)' : 'MONTHLY SUMMARY SHEET (BY MESS MANAGER)';
  String get currentMealRate => isBangla ? 'বর্তমান মিল রেট' : 'CURRENT MEAL RATE';
  String get pdfReceivables => isBangla ? 'প্রাপ্য' : 'RECEIVABLES';
  String get pdfPayables => isBangla ? 'পরিশোধ্য' : 'PAYABLES';
  String get pdfTotalCost => isBangla ? 'মোট খরচ' : 'TOTAL COST';
  String get pdfTotalPayments => isBangla ? 'মোট পেমেন্ট' : 'TOTAL PAYMENTS';
  String get pdfTotalMeals => isBangla ? 'মোট মিল' : 'TOTAL MEALS';
  String get guestMealsReportPDF => isBangla ? 'অতিথি মিল রিপোর্ট' : 'GUEST MEALS REPORT';
}

class BanglaLocalizationsDelegate extends LocalizationsDelegate<BanglaLocalizations> {
  const BanglaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<BanglaLocalizations> load(Locale locale) => Future.value(BanglaLocalizations(locale));

  @override
  bool shouldReload(BanglaLocalizationsDelegate old) => false;
}
