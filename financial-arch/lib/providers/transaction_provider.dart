import 'package:flutter/foundation.dart';
import '../models/index.dart';
import '../database/index.dart';

/// Provider for managing transaction-related state and operations
class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _incomeTransactions = [];
  List<TransactionModel> _expenseTransactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TransactionModel> get allTransactions => _allTransactions;
  List<TransactionModel> get incomeTransactions => _incomeTransactions;
  List<TransactionModel> get expenseTransactions => _expenseTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and load all transactions
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTransactions = await _dbHelper.getAllTransactions();
      _incomeTransactions = await _dbHelper.getTransactionsByType('INCOME');
      _expenseTransactions = await _dbHelper.getTransactionsByType('EXPENSE');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      return await _dbHelper.getTransactionById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      _error = null;
      return await _dbHelper.getTransactionsByType(type);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get transactions by category ID
  Future<List<TransactionModel>> getTransactionsByCategory(
      int categoryId) async {
    try {
      _error = null;
      return await _dbHelper.getTransactionsByCategory(categoryId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get transactions within a date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _error = null;
      return await _dbHelper.getTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Add a new transaction
  Future<int> addTransaction(TransactionModel transaction) async {
    try {
      _error = null;
      final id = await _dbHelper.insertTransaction(transaction);
      await loadTransactions();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return -1;
    }
  }

  /// Update an existing transaction by ID
  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      _error = null;
      final result = await _dbHelper.updateTransaction(transaction);
      if (result > 0) {
        await loadTransactions();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a transaction by ID
  Future<bool> deleteTransaction(int id) async {
    try {
      _error = null;
      final result = await _dbHelper.deleteTransaction(id);
      if (result > 0) {
        await loadTransactions();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get total income for a date range
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    try {
      _error = null;
      return await _dbHelper.getTotalIncome(startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  /// Get total expense for a date range
  Future<double> getTotalExpense(DateTime startDate, DateTime endDate) async {
    try {
      _error = null;
      return await _dbHelper.getTotalExpense(startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  /// Get spending by category
  Future<Map<int, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _error = null;
      return await _dbHelper.getSpendingByCategory(startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }
}
