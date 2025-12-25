import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving authentication tokens
class SecureStorageService {
  static const _jwtTokenKey = 'jwt_token';
  static const _firebaseTokenKey = 'firebase_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userFirstnameKey = 'user_firstname';
  static const _userLastnameKey = 'user_lastname';

  // Create storage instance with secure options
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ==================== JWT Token ====================

  /// Save JWT token from NestJS
  static Future<void> saveJwtToken(String token) async {
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  /// Get JWT token
  static Future<String?> getJwtToken() async {
    return await _storage.read(key: _jwtTokenKey);
  }

  /// Delete JWT token
  static Future<void> deleteJwtToken() async {
    await _storage.delete(key: _jwtTokenKey);
  }

  // ==================== Firebase Token ====================

  /// Save Firebase custom token (usually temporary)
  static Future<void> saveFirebaseToken(String token) async {
    await _storage.write(key: _firebaseTokenKey, value: token);
  }

  /// Get Firebase custom token
  static Future<String?> getFirebaseToken() async {
    return await _storage.read(key: _firebaseTokenKey);
  }

  /// Delete Firebase custom token
  static Future<void> deleteFirebaseToken() async {
    await _storage.delete(key: _firebaseTokenKey);
  }

  // ==================== User Data ====================

  /// Save user ID
  static Future<void> saveUserId(int userId) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final userIdString = await _storage.read(key: _userIdKey);
    if (userIdString == null) return null;
    return int.tryParse(userIdString);
  }

  /// Save user email
  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Save user first name
  static Future<void> saveUserFirstname(String firstname) async {
    await _storage.write(key: _userFirstnameKey, value: firstname);
  }

  /// Get user first name
  static Future<String?> getUserFirstname() async {
    return await _storage.read(key: _userFirstnameKey);
  }

  /// Save user last name
  static Future<void> saveUserLastname(String lastname) async {
    await _storage.write(key: _userLastnameKey, value: lastname);
  }

  /// Get user last name
  static Future<String?> getUserLastname() async {
    return await _storage.read(key: _userLastnameKey);
  }

  // ==================== Batch Operations ====================

  /// Save all user data and tokens at once
  static Future<void> saveAuthData({
    required String jwtToken,
    required int userId,
    required String email,
    required String firstname,
    required String lastname,
    String? firebaseToken,
  }) async {
    await Future.wait([
      saveJwtToken(jwtToken),
      saveUserId(userId),
      saveUserEmail(email),
      saveUserFirstname(firstname),
      saveUserLastname(lastname),
      if (firebaseToken != null) saveFirebaseToken(firebaseToken),
    ]);
  }

  /// Clear all stored authentication data
  static Future<void> clearAll() async {
    await Future.wait([
      deleteJwtToken(),
      deleteFirebaseToken(),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userFirstnameKey),
      _storage.delete(key: _userLastnameKey),
    ]);
  }

  /// Check if user is authenticated (has JWT token)
  static Future<bool> isAuthenticated() async {
    final token = await getJwtToken();
    return token != null && token.isNotEmpty;
  }

  /// Get all stored data (for debugging - use carefully)
  static Future<Map<String, String>> getAllData() async {
    final all = await _storage.readAll();
    return all;
  }
}
