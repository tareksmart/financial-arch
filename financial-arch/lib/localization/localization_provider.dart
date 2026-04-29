import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_strings.dart';

/// Provider for managing app localization and language switching
class LocalizationProvider extends ChangeNotifier {
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  String translate(String key) {
    return AppStrings.translate(key, locale: _currentLocale);
  }

  /// Change language and notify listeners
  Future<void> setLocale(String locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  /// Initialize locale from settings (will be called from SettingsProvider)
  void initializeLocale(String locale) {
    _currentLocale = locale;
  }

  /// Get locale object for Material app
  Locale getLocale() {
    if (_currentLocale == 'ar') {
      return const Locale('ar', 'SA');
    }
    return const Locale('en', 'US');
  }

  /// Check if current locale is Arabic
  bool get isArabic => _currentLocale == 'ar';

  /// Get text direction based on locale
  TextDirection getTextDirection() {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}
