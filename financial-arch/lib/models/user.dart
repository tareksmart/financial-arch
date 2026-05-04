/// User model representing app user accounts
class UserModel {
  final int? id;
  final String email;
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    this.id,
    required this.email,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    this.lastLogin,
  });

  /// Create a User from a database map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastLogin: map['last_login'] != null
          ? DateTime.parse(map['last_login'] as String)
          : null,
    );
  }

  /// Convert User to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ username.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, email: $email, username: $username, createdAt: $createdAt)';
}
