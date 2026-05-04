import 'package:crypto/crypto.dart';

/// Utility class for password hashing and verification
class PasswordEncryption {
  PasswordEncryption._();

  /// Hash a password using SHA256 with salt
  /// Returns the hashed password in format: hash$salt
  static String hashPassword(String password) {
    // Generate a simple salt by hashing part of the password with current timestamp
    final salt = sha256
        .convert((password + DateTime.now().toString()).codeUnits)
        .toString()
        .substring(0, 16);

    // Hash the password with the salt
    final hash = sha256.convert((password + salt).codeUnits).toString();

    // Return combined hash and salt
    return '$hash\$$salt';
  }

  /// Verify a password against a hash
  /// The hash should be in format: hash$salt (as returned by hashPassword)
  static bool verifyPassword(String password, String hash) {
    try {
      final parts = hash.split('\$');
      if (parts.length != 2) {
        return false;
      }

      final storedHash = parts[0];
      final salt = parts[1];

      // Re-hash the provided password with the stored salt
      final computedHash =
          sha256.convert((password + salt).codeUnits).toString();

      // Compare the computed hash with the stored hash
      return computedHash == storedHash;
    } catch (e) {
      return false;
    }
  }
}
