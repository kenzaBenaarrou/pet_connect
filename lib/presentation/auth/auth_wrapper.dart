import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_con/data/services/firebase_service.dart';
import 'package:pet_con/presentation/auth/login_screen.dart';
import 'package:pet_con/presentation/home/main_navigation.dart';
import 'package:pet_con/presentation/onboarding/onboarding_screen.dart';
import 'package:pet_con/data/repositories/owner_repository.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: FirebaseService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is not signed in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // User is signed in, check if profile exists
        final user = snapshot.data!;
        return FutureBuilder(
          future: ref.read(ownerRepositoryProvider).getOwnerProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Profile doesn't exist, go to onboarding
            if (!profileSnapshot.hasData || profileSnapshot.data == null) {
              return const OnboardingScreen();
            }

            // Profile exists, go to main app
            return const MainNavigation();
          },
        );
      },
    );
  }
}
