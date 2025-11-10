import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<void> initialize() async {
    // Configure Firestore settings
    try {
      // Only enable network if Firestore is accessible
      await firestore.enableNetwork();
      log('✅ FirebaseService initialized successfully');
    } catch (e) {
      log('⚠️ FirebaseService network enable failed: $e');
      // Don't throw, just continue
    }

    // Configure Storage settings if needed
    // await storage.setMaxUploadRetryTime(Duration(seconds: 60));
  }

  // Authentication Methods
  static Future<UserCredential?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  static Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  static Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw Exception('Apple Sign-In failed: $e');
    }
  }

  static Future<void> signOut() async {
    await Future.wait([
      auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Firestore Helper Methods
  static CollectionReference get ownersCollection =>
      firestore.collection('owners');

  static CollectionReference get petsCollection => firestore.collection('pets');

  static CollectionReference get matchesCollection =>
      firestore.collection('matches');

  static CollectionReference get messagesCollection =>
      firestore.collection('messages');

  static CollectionReference get swipesCollection =>
      firestore.collection('swipes');

  // Storage Helper Methods
  static Reference get profileImagesRef =>
      storage.ref().child('profile_images');

  static Reference get petImagesRef => storage.ref().child('pet_images');

  // Error Handling
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Current User Helper
  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => auth.currentUser?.uid;
  static bool get isSignedIn => auth.currentUser != null;

  // Auth State Stream
  static Stream<User?> get authStateChanges => auth.authStateChanges();
}
