/// Category model representing transaction categories in the app.
class CategoryModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String type; // 'INCOME' or 'EXPENSE'
  final String? iconName;
  final String? colorHex;

  CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    this.iconName,
    this.colorHex,
  });

  /// Create a Category from a database map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int,
      nameAr: map['name_ar'] as String,
      nameEn: map['name_en'] as String,
      type: map['type'] as String,
      iconName: map['icon_name'] as String?,
      colorHex: map['color_hex'] as String?,
    );
  }

  /// Convert Category to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'type': type,
      'icon_name': iconName,
      'color_hex': colorHex,
    };
  }

  /// Create a copy with optional field overrides
  CategoryModel copyWith({
    int? id,
    String? nameAr,
    String? nameEn,
    String? type,
    String? iconName,
    String? colorHex,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameAr == other.nameAr &&
          nameEn == other.nameEn &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^ nameAr.hashCode ^ nameEn.hashCode ^ type.hashCode;
}
