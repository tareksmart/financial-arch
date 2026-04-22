import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/index.dart';

/// DatabaseHelper class for managing SQLite database operations.
/// All queries use the ID (Record Code) as the primary identifier.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'financial_architect.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_ar TEXT NOT NULL,
        name_en TEXT NOT NULL,
        type TEXT CHECK(type IN ('INCOME', 'EXPENSE')) NOT NULL,
        icon_name TEXT,
        color_hex TEXT
      )
    ''');

    // Create Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        amount REAL NOT NULL,
        type TEXT CHECK(type IN ('INCOME', 'EXPENSE')) NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        voice_note_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // Create Settings Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Seed Initial Categories
    await _seedCategories(db);

    // Seed Initial Settings
    await _seedSettings(db);
  }

  Future<void> _seedCategories(Database db) async {
    final categories = [
      {
        'name_ar': 'راتب',
        'name_en': 'Salary',
        'type': 'INCOME',
        'icon_name': 'payments',
        'color_hex': '#4CAF50',
      },
      {
        'name_ar': 'عمل حر',
        'name_en': 'Freelance',
        'type': 'INCOME',
        'icon_name': 'work',
        'color_hex': '#8BC34A',
      },
      {
        'name_ar': 'هدية',
        'name_en': 'Gift',
        'type': 'INCOME',
        'icon_name': 'card_giftcard',
        'color_hex': '#2196F3',
      },
      {
        'name_ar': 'طعام وشراب',
        'name_en': 'Dining & Drinks',
        'type': 'EXPENSE',
        'icon_name': 'restaurant',
        'color_hex': '#FF6F00',
      },
      {
        'name_ar': 'مواصلات',
        'name_en': 'Transport',
        'type': 'EXPENSE',
        'icon_name': 'directions_car',
        'color_hex': '#00BCD4',
      },
      {
        'name_ar': 'تسوق',
        'name_en': 'Shopping',
        'type': 'EXPENSE',
        'icon_name': 'shopping_bag',
        'color_hex': '#E91E63',
      },
      {
        'name_ar': 'عقارات',
        'name_en': 'Real Estate',
        'type': 'EXPENSE',
        'icon_name': 'home',
        'color_hex': '#9C27B0',
      },
      {
        'name_ar': 'صحة',
        'name_en': 'Healthcare',
        'type': 'EXPENSE',
        'icon_name': 'local_hospital',
        'color_hex': '#F44336',
      },
      {
        'name_ar': 'ترفيه',
        'name_en': 'Entertainment',
        'type': 'EXPENSE',
        'icon_name': 'movie',
        'color_hex': '#673AB7',
      },
      {
        'name_ar': 'فواتير',
        'name_en': 'Utilities',
        'type': 'EXPENSE',
        'icon_name': 'electric_bolt',
        'color_hex': '#FFC107',
      },
    ];

    for (var category in categories) {
      await db.insert('categories', category);
    }
  }

  Future<void> _seedSettings(Database db) async {
    final settings = [
      {'key': 'language', 'value': 'en'},
      {'key': 'currency', 'value': 'EGP'},
      {'key': 'theme', 'value': 'light'},
    ];

    for (var setting in settings) {
      await db.insert('settings', setting);
    }
  }

  // ============ CATEGORY OPERATIONS ============

  /// Insert a new category
  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert(
        'categories',
        {
          'name_ar': category.nameAr,
          'name_en': category.nameEn,
          'type': category.type,
          'icon_name': category.iconName,
          'color_hex': category.colorHex,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  /// Get categories by type (INCOME or EXPENSE)
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  /// Get a single category by ID (Record Code)
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  /// Update a category by ID (Record Code)
  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete a category by ID (Record Code)
  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ============ TRANSACTION OPERATIONS ============

  /// Insert a new transaction
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert(
        'transactions',
        {
          'category_id': transaction.categoryId,
          'amount': transaction.amount,
          'type': transaction.type,
          'date': transaction.date.toIso8601String(),
          'note': transaction.note,
          'voice_note_path': transaction.voiceNotePath,
          'created_at': transaction.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  /// Get a single transaction by ID (Record Code)
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// Get transactions by type (INCOME or EXPENSE)
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  /// Get transactions by category ID
  Future<List<TransactionModel>> getTransactionsByCategory(
      int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  /// Get transactions within a date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  /// Update a transaction by ID (Record Code)
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      {
        'category_id': transaction.categoryId,
        'amount': transaction.amount,
        'type': transaction.type,
        'date': transaction.date.toIso8601String(),
        'note': transaction.note,
        'voice_note_path': transaction.voiceNotePath,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Delete a transaction by ID (Record Code)
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ============ SETTINGS OPERATIONS ============

  /// Set a setting (insert or replace)
  Future<int> setSetting(String key, String value) async {
    final db = await database;
    return await db.insert(
        'settings',
        {
          'key': key,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get a setting by key
  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  /// Get all settings
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final maps = await db.query('settings');
    final settings = <String, String>{};
    for (var map in maps) {
      settings[map['key'] as String] = map['value'] as String;
    }
    return settings;
  }

  /// Delete a setting by key
  Future<int> deleteSetting(String key) async {
    final db = await database;
    return await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  // ============ ANALYTICS OPERATIONS ============

  /// Get total income for a date range
  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date BETWEEN ? AND ?',
      ['INCOME', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return result.isNotEmpty
        ? (result.first['total'] as num?)?.toDouble() ?? 0.0
        : 0.0;
  }

  /// Get total expense for a date range
  Future<double> getTotalExpense(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND date BETWEEN ? AND ?',
      ['EXPENSE', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return result.isNotEmpty
        ? (result.first['total'] as num?)?.toDouble() ?? 0.0
        : 0.0;
  }

  /// Get spending by category
  Future<Map<int, double>> getSpendingByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category_id, SUM(amount) as total FROM transactions WHERE type = ? AND date BETWEEN ? AND ? GROUP BY category_id',
      ['EXPENSE', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final spending = <int, double>{};
    for (var row in result) {
      final categoryId = row['category_id'] as int?;
      if (categoryId != null) {
        spending[categoryId] = (row['total'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return spending;
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
