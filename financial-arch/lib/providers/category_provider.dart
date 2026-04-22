import 'package:flutter/foundation.dart';
import '../models/index.dart' hide CategoryModel;
import '../models/category.dart';

import '../database/index.dart';

/// Provider for managing category-related state and operations
class CategoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _incomeCategories = [];
  List<CategoryModel> _expenseCategories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CategoryModel> get allCategories => _allCategories;
  List<CategoryModel> get incomeCategories => _incomeCategories;
  List<CategoryModel> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize and load all categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCategories = await _dbHelper.getAllCategories();
      _incomeCategories = await _dbHelper.getCategoriesByType('INCOME');
      _expenseCategories = await _dbHelper.getCategoriesByType('EXPENSE');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    try {
      return await _dbHelper.getCategoryById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Add a new category
  Future<int> addCategory(CategoryModel category) async {
    try {
      _error = null;
      final id = await _dbHelper.insertCategory(category);
      await loadCategories();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return -1;
    }
  }

  /// Update an existing category by ID
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      _error = null;
      final result = await _dbHelper.updateCategory(category);
      if (result > 0) {
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a category by ID
  Future<bool> deleteCategory(int id) async {
    try {
      _error = null;
      final result = await _dbHelper.deleteCategory(id);
      if (result > 0) {
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
