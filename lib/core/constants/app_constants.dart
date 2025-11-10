import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Paw-some palette
  static const primaryBlue = Color(0xFF6C63FF);
  static const primaryPink = Color(0xFFFF6B9D);
  static const primaryCream = Color(0xFFFFF8E1);
  static const primaryWhite = Color(0xFFFFFFFF);

  // Secondary Colors
  static const secondaryBlue = Color(0xFF9C88FF);
  static const secondaryPink = Color(0xFFFFB3C6);
  static const accentOrange = Color(0xFFFFB347);
  static const accentGreen = Color(0xFF4ECDC4);

  // Text Colors
  static const textPrimary = Color(0xFF2D3142);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);

  // Background Colors
  static const backgroundLight = Color(0xFFF9FAFB);
  static const backgroundDark = Color(0xFF1F2937);
  static const cardBackground = Color(0xFFFFFFFF);

  // Action Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Swipe Colors
  static const swipeGreen = Color(0xFF4ADE80); // Like/Right swipe
  static const swipeRed = Color(0xFFEF4444); // Pass/Left swipe
  static const swipeGold = Color(0xFFFFD700); // Super Like
}

class AppDimensions {
  // Padding & Margins
  static const paddingXS = 4.0;
  static const paddingS = 8.0;
  static const paddingM = 16.0;
  static const paddingL = 24.0;
  static const paddingXL = 32.0;
  static const paddingXXL = 48.0;

  // Border Radius
  static const radiusS = 8.0;
  static const radiusM = 12.0;
  static const radiusL = 16.0;
  static const radiusXL = 24.0;
  static const radiusCircle = 50.0;

  // Card dimensions
  static const cardHeight = 600.0;
  static const cardWidth = 350.0;
  static const petImageHeight = 400.0;

  // Bottom Navigation
  static const bottomNavHeight = 80.0;
}

class AppFonts {
  static const fontFamily = 'Poppins';

  // Font Sizes
  static const sizeXS = 12.0;
  static const sizeS = 14.0;
  static const sizeM = 16.0;
  static const sizeL = 18.0;
  static const sizeXL = 20.0;
  static const sizeXXL = 24.0;
  static const sizeTitle = 28.0;
  static const sizeHeadline = 32.0;
}

class AppStrings {
  // App
  static const appName = 'PetConnect';
  static const tagline = 'Find Perfect Playmates for Your Pet';

  // Authentication
  static const signIn = 'Sign In';
  static const signUp = 'Sign Up';
  static const signOut = 'Sign Out';
  static const continueWithGoogle = 'Continue with Google';
  static const continueWithApple = 'Continue with Apple';
  static const email = 'Email';
  static const password = 'Password';
  static const confirmPassword = 'Confirm Password';
  static const forgotPassword = 'Forgot Password?';

  // Onboarding
  static const welcomeTitle = 'Welcome to PetConnect!';
  static const welcomeSubtitle =
      'Let\'s set up your profile and find pawsome playmates';
  static const setupProfile = 'Setup Profile';
  static const addPetProfile = 'Add Pet Profile';
  static const tellUsAboutYou = 'Tell us about you';
  static const tellUsAboutPet = 'Tell us about your pet';

  // Navigation
  static const home = 'Home';
  static const matches = 'Matches';
  static const chat = 'Chat';
  static const profile = 'Profile';

  // Swipe
  static const itsAMatch = 'It\'s a Paw-fect Match!';
  static const matchSubtitle = 'You and {petName} liked each other';
  static const startChatting = 'Start Chatting';
  static const keepSwiping = 'Keep Swiping';

  // Pet Details
  static const age = 'Age';
  static const breed = 'Breed';
  static const size = 'Size';
  static const temperament = 'Temperament';
  static const vaccinated = 'Vaccinated';
  static const fixed = 'Fixed/Neutered';
  static const aboutPet = 'About {petName}';

  // Safety
  static const safetyTip =
      'Safety Tip: Always meet in public places like dog parks';

  // Filters
  static const discoverySettings = 'Discovery Settings';
  static const distance = 'Distance';
  static const ageRange = 'Age Range';
  static const petSize = 'Pet Size';
  static const miles = 'miles';

  // Common
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const next = 'Next';
  static const skip = 'Skip';
  static const done = 'Done';
  static const loading = 'Loading...';
  static const retry = 'Retry';
  static const errorOccurred = 'An error occurred';
}

class AppConstants {
  // API & Firebase
  static const defaultProfileImage = 'https://via.placeholder.com/150';
  static const maxPetImages = 6;
  static const maxMessageLength = 500;

  // Discovery Settings
  static const minDistance = 1;
  static const maxDistance = 100;
  static const defaultDistance = 25;

  static const minAge = 0;
  static const maxAge = 20;

  // Pet Sizes
  static const petSizes = ['Small', 'Medium', 'Large', 'Extra Large'];

  // Temperaments
  static const temperaments = [
    'Friendly',
    'Energetic',
    'Calm',
    'Playful',
    'Shy',
    'Aggressive',
    'Social',
    'Independent',
    'Loyal',
    'Protective',
  ];

  // Animation Durations
  static const animationDurationShort = Duration(milliseconds: 300);
  static const animationDurationMedium = Duration(milliseconds: 500);
  static const animationDurationLong = Duration(milliseconds: 800);
}
