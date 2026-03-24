import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_con/data/services/firebase_service.dart';
import 'package:pet_con/data/repositories/auth_api_repository.dart';
import 'package:pet_con/data/models/user_model.dart';
import 'package:pet_con/data/services/secure_storage_service.dart';

// Auth State - Now uses custom UserModel instead of Firebase User
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier - Now uses NestJS backend with Firebase custom tokens
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiRepository _authRepo;

  AuthNotifier(this._authRepo) : super(const AuthState()) {
    _init();
  }

  void _init() async {
    // Check if user is already authenticated
    final isAuthenticated = await _authRepo.isAuthenticated();
    if (isAuthenticated) {
      try {
        // Get user from backend
        final user = await _authRepo.getCurrentUser();

        // Check if Firebase user exists, if not sign in with custom token
        if (FirebaseAuth.instance.currentUser == null) {
          final firebaseToken = await SecureStorageService.getFirebaseToken();
          if (firebaseToken != null) {
            await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          }
        }

        // Update Firebase UID in user model
        final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
        state = state.copyWith(
          user: user.copyWith(firebaseUid: firebaseUid),
          isLoading: false,
        );
      } catch (e) {
        // If token is invalid, clear storage
        await SecureStorageService.clearAll();
        state = state.copyWith(user: null, isLoading: false);
      }
    }

    // Listen to Firebase auth state changes for real-time updates
    FirebaseService.authStateChanges.listen((firebaseUser) {
      if (state.user != null && firebaseUser != null) {
        // Update firebaseUid in our custom user model
        state = state.copyWith(
          user: state.user!.copyWith(firebaseUid: firebaseUser.uid),
        );
      } else if (firebaseUser == null && state.user != null) {
        // Firebase session expired, try to refresh
        _refreshFirebaseAuth();
      }
    });
  }

  /// Sign in with email and password through NestJS backend
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Call NestJS login endpoint
      final response = await _authRepo.login(
        email: email,
        password: password,
      );

      final user = response['user'] as UserModel;
      final firebaseToken = response['firebase_token'] as String;

      log('Firebase token received: $firebaseToken');
      log('Firebase token length: ${firebaseToken.length}');

      // Sign in to Firebase with custom token
      final firebaseCredential =
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      log('Signed in to Firebase with UID: ${firebaseCredential.user?.uid}');
      final updatedUser = user.copyWith(
        firebaseUid: firebaseCredential.user?.uid,
      );

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign up with email and password through NestJS backend
  Future<void> signUpWithEmail(
    String firstname,
    String lastname,
    String email,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Call NestJS register endpoint
      final response = await _authRepo.register(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
      );

      final user = response['user'] as UserModel;
      final firebaseToken = response['firebase_token'] as String;

      // Sign in to Firebase with custom token
      final firebaseCredential =
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);

      // Update user with Firebase UID
      final updatedUser = user.copyWith(
        firebaseUid: firebaseCredential.user?.uid,
      );

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign in with Google (still uses Firebase Auth directly)
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await FirebaseService.signInWithGoogle();

      if (result?.user != null) {
        // For now, create a basic UserModel with placeholder data
        final firebaseUser = result!.user!;
        final displayName = firebaseUser.displayName ?? 'User';
        final nameParts = displayName.split(' ');
        final user = UserModel(
          id: 0, // Placeholder - will be set by backend
          firstname: nameParts.isNotEmpty ? nameParts[0] : 'User',
          lastname: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          email: firebaseUser.email ?? '',
          photo: firebaseUser.photoURL,
          firebaseUid: firebaseUser.uid,
        );
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign in with Apple (still uses Firebase Auth directly)
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await FirebaseService.signInWithApple();

      if (result?.user != null) {
        // TODO: Send Apple user info to NestJS to create/link account
        // For now, create a basic UserModel with placeholder data
        final firebaseUser = result!.user!;
        final displayName = firebaseUser.displayName ?? 'User';
        final nameParts = displayName.split(' ');
        final user = UserModel(
          id: 0, // Placeholder - will be set by backend
          firstname: nameParts.isNotEmpty ? nameParts[0] : 'User',
          lastname: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          email: firebaseUser.email ?? '',
          photo: firebaseUser.photoURL,
          firebaseUid: firebaseUser.uid,
        );
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Sign out from both NestJS and Firebase
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Clear local storage (JWT tokens)
      await _authRepo.logout();

      // Sign out from Firebase
      await FirebaseService.signOut();

      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Send password reset email (handled by NestJS backend)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // TODO: Implement password reset endpoint in NestJS
      // For now, use Firebase password reset
      await FirebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh Firebase authentication with new custom token
  Future<void> _refreshFirebaseAuth() async {
    try {
      final firebaseToken = await _authRepo.refreshFirebaseToken();
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
    } catch (e) {
      // If refresh fails, sign out completely
      await signOut();
    }
  }
}

// Providers
final authRepoProvider = Provider<AuthApiRepository>((ref) {
  return AuthApiRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepoProvider);
  return AuthNotifier(authRepo);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});
