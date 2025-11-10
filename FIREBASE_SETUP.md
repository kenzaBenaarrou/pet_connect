# Firebase Setup Guide for PetConnect

This guide will help you set up Firebase for the PetConnect app.

## Prerequisites

1. Google account
2. Flutter development environment set up
3. Android Studio or Xcode (for mobile development)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `petconnect-app`
4. Enable Google Analytics (recommended)
5. Choose or create a Google Analytics account
6. Click "Create project"

## Step 2: Add Android App

1. In Firebase console, click "Add app" and select Android
2. Enter package name: `com.example.pet_con` (or your chosen package name)
3. Enter app nickname: `PetConnect Android`
4. Enter SHA-1 certificate fingerprint (optional for now)
5. Click "Register app"
6. Download `google-services.json`
7. Place the file in `android/app/` directory

### Android Configuration

1. In `android/build.gradle`, add:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. In `android/app/build.gradle`, add:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

## Step 3: Add iOS App

1. In Firebase console, click "Add app" and select iOS
2. Enter bundle ID: `com.example.petCon` (or your chosen bundle ID)
3. Enter app nickname: `PetConnect iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Add the file to `ios/Runner/` directory in Xcode

### iOS Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on `Runner` folder and select "Add Files to Runner"
3. Select `GoogleService-Info.plist` and ensure it's added to the `Runner` target

## Step 4: Enable Authentication

1. In Firebase console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable the following providers:
   - Email/Password
   - Google (configure OAuth consent screen)
   - Apple (for iOS, configure Apple Sign-In)

### Google Sign-In Setup

1. Go to "Authentication" > "Sign-in method"
2. Click on "Google"
3. Enable Google Sign-In
4. Set the project support email
5. Download the config files again if prompted

### Apple Sign-In Setup (iOS only)

1. In Apple Developer Console, enable Sign In with Apple capability
2. In Firebase console, enable Apple provider
3. Configure the service ID and key
4. In Xcode, add "Sign In with Apple" capability to your app

## Step 5: Set up Firestore Database

1. In Firebase console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location closest to your users
5. Click "Done"

### Firestore Security Rules (Development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Firestore Collections Structure

The app will create these collections:
- `users` - User profiles and settings
- `pets` - Pet profiles
- `matches` - Match relationships
- `chats` - Chat conversations
- `messages` - Individual messages

## Step 6: Set up Firebase Storage

1. In Firebase console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode"
4. Select a location
5. Click "Done"

### Storage Security Rules (Development)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 7: Update Flutter Configuration

1. Run the following commands in your project root:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

2. Follow the prompts to select your Firebase project and platforms

## Step 8: Generate Required Files

Run the following command to generate the JSON serialization code:

```bash
flutter packages pub run build_runner build
```

## Step 9: Test the Setup

1. Run the app on a device or emulator:
```bash
flutter run
```

2. Try creating an account and signing in
3. Check Firebase console to see if users are being created

## Production Configuration

Before releasing to production:

1. **Update Firestore Security Rules** to be more restrictive
2. **Update Storage Security Rules** to validate file types and sizes
3. **Configure proper OAuth consent screens**
4. **Set up proper app signing certificates**
5. **Review and update privacy policies**

## Troubleshooting

### Common Issues

1. **Build errors after adding Firebase**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check that all configuration files are in the correct locations

2. **Authentication not working**
   - Verify package names/bundle IDs match Firebase configuration
   - Check that authentication providers are enabled in Firebase console

3. **iOS build issues**
   - Ensure `GoogleService-Info.plist` is added to the Xcode project
   - Check iOS deployment target is 11.0 or higher

4. **Android build issues**
   - Verify `google-services.json` is in `android/app/`
   - Check that gradle plugins are correctly applied

### Getting Help

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Firebase Codelab](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)

## Security Best Practices

1. Use environment variables for sensitive configuration
2. Implement proper Firestore security rules
3. Validate all user inputs
4. Use Firebase App Check for additional security
5. Regularly review and update security rules
6. Monitor usage in Firebase console

## Next Steps

After Firebase setup is complete:
1. Test authentication flow
2. Test pet profile creation and image upload
3. Implement real-time features (chat, matches)
4. Add push notifications
5. Implement geolocation features
6. Add proper error handling and offline support