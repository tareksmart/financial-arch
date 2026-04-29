/// Application strings for both English and Arabic
class AppStrings {
  // English translations
  static const Map<String, String> enUS = {
    // App & Navigation
    'app_name': 'Financial Architect',
    'financial_architect': 'Financial Architect',

    // Home Screen
    'net_daily_balance': 'Net Daily Balance',
    'balance_today': 'balance today',
    'income': 'Income',
    'spent': 'Spent',
    'recent_transactions': 'Recent Transactions',
    'no_transactions_yet': 'No transactions yet',
    'record_expense': 'Record Expense',
    'record_income': 'Record Income',

    // Transaction Form
    'expense': 'Expense',
    'income_label': 'Income',
    'amount': 'Amount',
    'category': 'Category',
    'details_optional': 'Details (Optional)',
    'tap_mic_or_type': 'Tap mic or type your notes...',
    'select_category': 'Select Category',
    'please_fill_all_fields': 'Please fill all fields',
    'transaction_recorded': 'Transaction recorded successfully',

    // History Screen
    'transaction_history': 'Transaction History',
    'all': 'All',
    'no_transactions_found': 'No transactions found',
    'edit_functionality': 'Edit functionality coming soon',
    'delete_transaction': 'Delete Transaction',
    'are_you_sure_delete': 'Are you sure you want to delete this transaction?',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'transaction_deleted': 'Transaction deleted',

    // Analytics Screen
    'analytics_dashboard': 'Analytics Dashboard',
    'expenses': 'Expenses',
    'monthly_balance': 'Monthly Balance',
    'spending_by_category': 'Spending by Category',
    'no_spending_data': 'No spending data',
    'day': 'Day',
    'month': 'Month',
    'year': 'Year',

    // Profile Screen
    'profile_settings': 'Profile & Settings',
    'user_profile': 'User Profile',
    'premium_member': 'Premium Member',
    'account_management': 'Account Management',
    'personal_information': 'Personal Information',
    'update_name_email': 'Update your name and email',
    'security_privacy': 'Security & Privacy',
    'two_factor_auth': 'Two-factor authentication',
    'app_preferences': 'App Preferences',
    'currency': 'Currency',
    'language': 'Language',
    'theme': 'Theme',
    'information': 'Information',
    'about_app': 'About Financial Architect',
    'version': 'Version 1.0.0',
    'legal_terms': 'Legal & Terms',
    'privacy_policy': 'Privacy Policy, Terms of Service',
    'logout': 'Logout',
    'select_currency': 'Select Currency',
    'select_language': 'Select Language',
    'english': 'English',
    'arabic': 'العربية',
    'light': 'Light',
    'dark': 'Dark',
  };

  // Arabic translations
  static const Map<String, String> arSA = {
    // App & Navigation
    'app_name': 'المهندس المالي',
    'financial_architect': 'المهندس المالي',

    // Home Screen
    'net_daily_balance': 'صافي الرصيد اليومي',
    'balance_today': 'الرصيد اليوم',
    'income': 'الدخل',
    'spent': 'الإنفاق',
    'recent_transactions': 'أحدث العمليات',
    'no_transactions_yet': 'لا توجد عمليات حتى الآن',
    'record_expense': 'تسجيل مصروف',
    'record_income': 'تسجيل دخل',

    // Transaction Form
    'expense': 'مصروف',
    'income_label': 'دخل',
    'amount': 'المبلغ',
    'category': 'الفئة',
    'details_optional': 'التفاصيل (اختياري)',
    'tap_mic_or_type': 'اضغط على الميكروفون أو اكتب ملاحظاتك...',
    'select_category': 'اختر فئة',
    'please_fill_all_fields': 'يرجى ملء جميع الحقول',
    'transaction_recorded': 'تم تسجيل العملية بنجاح',

    // History Screen
    'transaction_history': 'سجل العمليات',
    'all': 'الكل',
    'no_transactions_found': 'لم يتم العثور على عمليات',
    'edit_functionality': 'ستتوفر ميزة التعديل قريباً',
    'delete_transaction': 'حذف العملية',
    'are_you_sure_delete': 'هل أنت متأكد من رغبتك في حذف هذه العملية؟',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'transaction_deleted': 'تم حذف العملية',

    // Analytics Screen
    'analytics_dashboard': 'لوحة التحليلات',
    'expenses': 'المصاريف',
    'monthly_balance': 'الرصيد الشهري',
    'spending_by_category': 'الإنفاق حسب الفئة',
    'no_spending_data': 'لا توجد بيانات إنفاق',
    'day': 'يوم',
    'month': 'شهر',
    'year': 'سنة',

    // Profile Screen
    'profile_settings': 'الملف الشخصي والإعدادات',
    'user_profile': 'الملف الشخصي',
    'premium_member': 'عضو بريميوم',
    'account_management': 'إدارة الحساب',
    'personal_information': 'المعلومات الشخصية',
    'update_name_email': 'حدّث اسمك وبريدك الإلكتروني',
    'security_privacy': 'الأمان والخصوصية',
    'two_factor_auth': 'المصادقة الثنائية',
    'app_preferences': 'تفضيلات التطبيق',
    'currency': 'العملة',
    'language': 'اللغة',
    'theme': 'المظهر',
    'information': 'معلومات',
    'about_app': 'حول المهندس المالي',
    'version': 'الإصدار 1.0.0',
    'legal_terms': 'القانوني والشروط',
    'privacy_policy': 'سياسة الخصوصية وشروط الخدمة',
    'logout': 'تسجيل الخروج',
    'select_currency': 'اختر العملة',
    'select_language': 'اختر اللغة',
    'english': 'English',
    'arabic': 'العربية',
    'light': 'فاتح',
    'dark': 'داكن',
  };

  static String translate(String key, {String locale = 'en'}) {
    if (locale == 'ar') {
      return arSA[key] ?? key;
    }
    return enUS[key] ?? key;
  }
}
