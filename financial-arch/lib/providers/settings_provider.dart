import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../database/index.dart';
import '../localization/index.dart';

/// Provider for managing app settings and preferences
class SettingsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  LocalizationProvider? _localizationProvider;

  Map<String, String> _settings = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, String> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get language => _settings['language'] ?? 'ar';
  String get currency => _settings['currency'] ?? 'EGP';
  String get theme => _settings['theme'] ?? 'light';

  /// Set reference to LocalizationProvider
  void updateLocalizationProvider(LocalizationProvider localizationProvider) {
    _localizationProvider = localizationProvider;
  }

  /// Initialize and load all settings
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _dbHelper.getAllSettings();
      // Initialize localization with loaded language
      if (_localizationProvider != null) {
        _localizationProvider!.initializeLocale(_settings['language'] ?? 'ar');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single setting value
  Future<String?> getSetting(String key) async {
    try {
      _error = null;
      return await _dbHelper.getSetting(key);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Set a setting value
  Future<bool> setSetting(String key, String value) async {
    try {
      _error = null;
      await _dbHelper.setSetting(key, value);
      _settings[key] = value;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update language setting
  Future<bool> setLanguage(String languageCode) async {
    final result = await setSetting('language', languageCode);
    if (result && _localizationProvider != null) {
      await _localizationProvider!.setLocale(languageCode);
    }
    return result;
  }

  /// Update currency setting
  Future<bool> setCurrency(String currencyCode) async {
    return await setSetting('currency', currencyCode);
  }

  /// Update theme setting
  Future<bool> setTheme(String themeName) async {
    return await setSetting('theme', themeName);
  }

  /// Delete a setting
  Future<bool> deleteSetting(String key) async {
    try {
      _error = null;
      await _dbHelper.deleteSetting(key);
      _settings.remove(key);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

