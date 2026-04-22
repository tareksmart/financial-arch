/// Transaction model representing income/expense transactions.
class TransactionModel {
  final int id;
  final int? categoryId;
  final double amount;
  final String type; // 'INCOME' or 'EXPENSE'
  final DateTime date;
  final String? note;
  final String? voiceNotePath;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.voiceNotePath,
    required this.createdAt,
  });

  /// Create a Transaction from a database map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int,
      categoryId: map['category_id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      voiceNotePath: map['voice_note_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert Transaction to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
      'voice_note_path': voiceNotePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with optional field overrides
  TransactionModel copyWith({
    int? id,
    int? categoryId,
    double? amount,
    String? type,
    DateTime? date,
    String? note,
    String? voiceNotePath,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount &&
          type == other.type &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^ amount.hashCode ^ type.hashCode ^ date.hashCode;
}
