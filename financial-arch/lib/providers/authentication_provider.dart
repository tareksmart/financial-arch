import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../database/index.dart';
import '../utilities/password_encryption.dart';

/// Provider for managing user authentication
class AuthenticationProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Register a new user
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || username.isEmpty || password.isEmpty) {
        _error = 'All fields are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email already exists
      if (await _dbHelper.emailExists(email)) {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if username already exists
      if (await _dbHelper.usernameExists(username)) {
        _error = 'Username already taken';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Hash the password
      final passwordHash = PasswordEncryption.hashPassword(password);

      // Create user
      final user = UserModel(
        email: email,
        username: username,
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
      );

      // Register in database
      final result = await _dbHelper.registerUser(user);

      if (result > 0) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to register user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _error = 'Email and password are required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get user by email
      final user = await _dbHelper.getUserByEmail(email);

      if (user == null) {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verify password
      if (!PasswordEncryption.verifyPassword(password, user.passwordHash)) {
        _error = 'Invalid password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update last login
      await _dbHelper.updateUserLastLogin(user.id!);

      // Set current user
      _currentUser = user;
      _isAuthenticated = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if user is logged in (from stored session)
  Future<bool> checkAuthStatus() async {
    // This can be enhanced to persist user ID in shared preferences
    // For now, we assume user is not logged in after app restart
    _isAuthenticated = _currentUser != null;
    notifyListeners();
    return _isAuthenticated;
  }

  /// Logout user
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
