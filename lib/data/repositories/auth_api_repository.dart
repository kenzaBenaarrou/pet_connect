import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';

/// Repository for Authentication API calls to NestJS backend
class AuthApiRepository {
  final String baseUrl;
  final http.Client _client;

  AuthApiRepository({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  /// Register new user
  ///
  /// POST /auth/register
  /// Body: { "firstname": "...", "lastname": "...", "email": "...", "password": "..." }
  ///
  /// Returns: {
  ///   "user": { "id": 1, "firstname": "...", "lastname": "...", "email": "..." },
  ///   "access_token": "...",
  ///   "firebase_token": "..."
  /// }
  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract tokens
        final jwtToken = data['access_token'] as String;
        final firebaseToken = data['firebase_token'] as String;

        // Extract user data
        final userData = data['user'] as Map<String, dynamic>;

        // Create UserModel with tokens
        final user = UserModel.fromJson(userData).copyWith(
          jwtToken: jwtToken,
          firebaseToken: firebaseToken,
        );

        // Save tokens to secure storage
        await SecureStorageService.saveAuthData(
          jwtToken: jwtToken,
          userId: user.id!, // Convert int to string
          email: user.email ?? "",
          firstname: user.firstname ?? "",
          lastname: user.lastname ?? "",
          firebaseToken: firebaseToken,
        );

        return {
          'user': user,
          'access_token': jwtToken,
          'firebase_token': firebaseToken,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Login existing user
  ///
  /// POST /auth/login
  /// Body: { "email": "...", "password": "..." }
  ///
  /// Returns: {
  ///   "user": { "id": "...", "name": "...", "email": "..." },
  ///   "access_token": "...",
  ///   "firebase_token": "..."
  /// }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // log('Attempting login for email: $email , password: $password');
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // log('Login response status: $data');

        // Extract tokens
        final jwtToken = data['accessToken'] as String;
        final firebaseToken = data['firebaseToken'] as String;

        // Extract user data
        final userData = data['user'] as Map<String, dynamic>;

        // Create UserModel with tokens
        final user = UserModel.fromJson(userData).copyWith(
          jwtToken: jwtToken,
          firebaseToken: firebaseToken,
        );

        // Save tokens to secure storage
        await SecureStorageService.saveAuthData(
          jwtToken: jwtToken,
          userId: user.id!, // Convert int to string
          email: user.email ?? "",
          firstname: user.firstname ?? "",
          lastname: user.lastname ?? "",
          firebaseToken: firebaseToken,
        );

        return {
          'user': user,
          'access_token': jwtToken,
          'firebase_token': firebaseToken,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Get current user profile (requires JWT token)
  ///
  /// GET /auth/me
  /// Headers: { "Authorization": "Bearer <jwt_token>" }
  Future<UserModel> getCurrentUser() async {
    try {
      final jwtToken = await SecureStorageService.getJwtToken();
      final userId = await SecureStorageService.getUserId();
      if (jwtToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/users/id/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        log('Get current user response: ${response.body}');
        final userData = jsonDecode(response.body) as Map<String, dynamic>;
        log('Get current user response: ${userData}');

        log('User data retrieved: ${UserModel.fromJson(userData)}');
        return UserModel.fromJson(userData).copyWith(jwtToken: jwtToken);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Get current user error: $e');
    }
  }

  /// Refresh Firebase custom token
  ///
  /// GET /auth/refresh-firebase-token
  /// Headers: { "Authorization": "Bearer <jwt_token>" }
  ///
  /// Returns: { "firebase_token": "..." }
  Future<String> refreshFirebaseToken() async {
    try {
      final jwtToken = await SecureStorageService.getJwtToken();

      if (jwtToken == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse('$baseUrl/auth/refresh-firebase-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final firebaseToken = data['firebase_token'] as String;

        // Save new Firebase token
        await SecureStorageService.saveFirebaseToken(firebaseToken);

        return firebaseToken;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to refresh Firebase token');
      }
    } catch (e) {
      throw Exception('Refresh Firebase token error: $e');
    }
  }

  /// Logout (clear local tokens)
  Future<void> logout() async {
    await SecureStorageService.clearAll();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await SecureStorageService.isAuthenticated();
  }
}
