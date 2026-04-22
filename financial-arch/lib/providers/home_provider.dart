import 'package:flutter/foundation.dart';
import '../models/index.dart';
import 'transaction_provider.dart';

/// Provider for managing home screen state (balance, summaries)
class HomeProvider extends ChangeNotifier {
  final TransactionProvider transactionProvider;

  double _todayBalance = 0.0;
  double _todayIncome = 0.0;
  double _todayExpense = 0.0;
  double _monthlyBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;

  bool _isLoading = false;
  String? _error;

  HomeProvider({required this.transactionProvider});

  // Getters
  double get todayBalance => _todayBalance;
  double get todayIncome => _todayIncome;
  double get todayExpense => _todayExpense;

  double get monthlyBalance => _monthlyBalance;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all home screen data
  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = monthStart
          .add(const Duration(days: 32))
          .copyWith(day: 1);

      // Today's data
      _todayIncome = await transactionProvider.getTotalIncome(today, tomorrow);
      _todayExpense = await transactionProvider.getTotalExpense(
        today,
        tomorrow,
      );
      _todayBalance = _todayIncome - _todayExpense;

      // Monthly data
      _monthlyIncome = await transactionProvider.getTotalIncome(
        monthStart,
        monthEnd,
      );
      _monthlyExpense = await transactionProvider.getTotalExpense(
        monthStart,
        monthEnd,
      );
      _monthlyBalance = _monthlyIncome - _monthlyExpense;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get balance by date range
  Future<Map<String, double>> getBalanceByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _error = null;
      final income = await transactionProvider.getTotalIncome(
        startDate,
        endDate,
      );
      final expense = await transactionProvider.getTotalExpense(
        startDate,
        endDate,
      );
      return {
        'income': income,
        'expense': expense,
        'balance': income - expense,
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
    }
  }
}
