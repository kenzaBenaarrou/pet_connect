import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_con/presentation/auth/login_screen.dart';
import 'package:pet_con/presentation/home/main_navigation.dart';
import 'package:pet_con/presentation/onboarding/onboarding_screen.dart';
import 'package:pet_con/data/repositories/pet_api_repository.dart';
import 'package:pet_con/data/services/secure_storage_service.dart';

enum AuthStatus {
  notAuthenticated,
  needsOnboarding,
  authenticated,
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _checkAuthAndOnboarding(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check the authentication status
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final authStatus = snapshot.data!;

        // Not authenticated - go to login
        if (authStatus == AuthStatus.notAuthenticated) {
          return const LoginScreen();
        }

        // Authenticated but onboarding not complete
        if (authStatus == AuthStatus.needsOnboarding) {
          return const OnboardingScreen();
        }

        // Authenticated and onboarding complete
        return const MainNavigation();
      },
    );
  }

  Future<AuthStatus> _checkAuthAndOnboarding() async {
    try {
      // Check if user has JWT token (authenticated)
      final jwtToken = await SecureStorageService.getJwtToken();
      if (jwtToken == null) {
        log('No JWT token found, user not authenticated');
        return AuthStatus.notAuthenticated;
      }

      // Check onboarding status
      final hasCompletedOnboarding = await _checkOnboardingStatus();

      if (hasCompletedOnboarding == true) {
        return AuthStatus.authenticated;
      } else {
        return AuthStatus.needsOnboarding;
      }
    } catch (e) {
      log('Error checking auth status: $e');
      return AuthStatus.notAuthenticated;
    }
  }

  Future<bool?> _checkOnboardingStatus() async {
    try {
      // Get user ID from secure storage
      final userId = await SecureStorageService.getUserId();
      log('User ID for onboarding check: $userId');

      // If user ID is null, user needs to login again
      if (userId == null) {
        log('User ID is null, returning to login');
        return null;
      }

      // Check if user has any pets via NestJS API
      final petApiRepository = PetApiRepository();
      try {
        final pets = await petApiRepository.getPetsByOwner(userId);
        log('Found ${pets.length} pets for user $userId');

        // If they have at least one pet, onboarding is complete
        return pets.isNotEmpty;
      } catch (petError) {
        log('Error fetching pets: $petError');
        // If we get a 404 or similar, it means no pets exist yet
        // So onboarding is not complete
        return false;
      }
    } catch (e) {
      log('Error checking onboarding status: $e');
      // If error occurs, assume onboarding not complete
      return false;
    }
  }
}
