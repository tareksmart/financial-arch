/// Settings model for app preferences and configuration.
class AppSettings {
  final String key;
  final String value;

  AppSettings({required this.key, required this.value});

  /// Create AppSettings from a database map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }

  /// Convert AppSettings to a database map
  Map<String, dynamic> toMap() {
    return {'key': key, 'value': value};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
