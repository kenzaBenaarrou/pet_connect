# PetConnect Development Guide

This guide provides detailed information for developers working on the PetConnect app.

## Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd pet_con
   flutter pub get
   ```

2. **Firebase Setup**
   - Follow the [Firebase Setup Guide](./FIREBASE_SETUP.md)
   - Add configuration files (`google-services.json`, `GoogleService-Info.plist`)

3. **Generate Code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/                 # Core utilities and configurations
│   ├── constants/        # App constants and themes
│   ├── utils/           # Utility functions
│   └── widgets/         # Reusable widgets
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   └── services/        # External services (Firebase, etc.)
├── domain/              # Business logic layer
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
└── presentation/        # UI layer
    ├── auth/            # Authentication screens
    ├── home/            # Home and discovery screens
    ├── onboarding/      # Onboarding flow
    ├── profile/         # Profile management
    ├── chat/            # Chat functionality
    └── shared/          # Shared UI components
```

## Architecture

The app follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, screens, and state management
- **Domain Layer**: Business logic, entities, and use cases
- **Data Layer**: Data sources, repositories, and models

### State Management

Using **Riverpod** for state management:
- `StateNotifierProvider` for complex state
- `Provider` for simple dependencies
- `FutureProvider` for async operations
- `StreamProvider` for real-time data

## Key Features Implementation

### 1. Authentication
- Email/Password sign-in
- Google Sign-In
- Apple Sign-In (iOS)
- Password reset functionality

### 2. Onboarding Flow
- Welcome screen with app introduction
- User profile setup
- Pet profile creation
- Location permissions

### 3. Pet Discovery
- Swipe-based interface using `card_swiper`
- Like/Pass/Super Like actions
- Discovery filters (age, distance, breed)
- Empty states handling

### 4. Matching System
- Real-time match detection
- Match notifications
- Match list display

### 5. Chat System
- Real-time messaging with Firestore
- Image sharing
- Message status indicators

## Development Workflow

### 1. Feature Development

1. Create feature branch: `git checkout -b feature/feature-name`
2. Implement following clean architecture:
   - Start with domain layer (entities, use cases)
   - Implement data layer (models, repositories)
   - Build presentation layer (screens, providers)
3. Write tests for business logic
4. Update documentation
5. Create pull request

### 2. Code Generation

When modifying data models:
```bash
# Rebuild generated files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Or watch for changes
flutter packages pub run build_runner watch
```

### 3. Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Coding Standards

### 1. File Naming
- Use snake_case for file names
- Add descriptive suffixes (`_screen.dart`, `_provider.dart`, `_service.dart`)

### 2. Code Organization
- Group imports: Dart SDK, Flutter, packages, local
- Use relative imports for local files
- Export public APIs through barrel files

### 3. Widget Construction
- Extract complex widgets into separate files
- Use const constructors when possible
- Implement proper key usage for stateful widgets

### 4. State Management
- Keep providers close to where they're used
- Use meaningful provider names
- Implement proper dispose methods

## Firebase Integration

### Firestore Structure

```
users/{userId}
├── profile: OwnerProfile
├── pets/{petId}: PetProfile
├── matches/{matchId}: Match
└── chats/{chatId}
    └── messages/{messageId}: Message
```

### Security Rules

Development rules (test mode):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Production rules should be more restrictive.

## UI/UX Guidelines

### 1. Design System
- Material 3 design principles
- Consistent color palette from `app_constants.dart`
- Typography hierarchy using Poppins font

### 2. Responsive Design
- Use `ScreenUtil` for responsive dimensions
- Test on different screen sizes
- Support both portrait and landscape

### 3. Accessibility
- Add semantic labels
- Ensure proper contrast ratios
- Support screen readers

## Performance Optimization

### 1. Image Handling
- Use `cached_network_image` for network images
- Implement proper image compression
- Use placeholder images during loading

### 2. List Performance
- Use `ListView.builder` for large lists
- Implement pagination for data loading
- Use `AutomaticKeepAliveClientMixin` when needed

### 3. State Management
- Avoid unnecessary rebuilds
- Use `select` for partial state listening
- Implement proper provider disposal

## Debugging Tips

### 1. Common Issues
- **Hot reload not working**: Restart app after dependency changes
- **Build errors**: Check import statements and file paths
- **Firebase errors**: Verify configuration files placement

### 2. Debug Tools
- Flutter Inspector for widget tree
- Riverpod Inspector for state debugging
- Firebase console for backend data

### 3. Logging
```dart
import 'dart:developer' as developer;

// Use for debugging
developer.log('Debug message', name: 'PetConnect');
```

## Deployment

### 1. Pre-deployment Checklist
- [ ] Update version number in `pubspec.yaml`
- [ ] Test on physical devices
- [ ] Verify Firebase security rules
- [ ] Update app icons and splash screens
- [ ] Test authentication flows
- [ ] Verify all features work offline

### 2. Android Deployment
```bash
# Build release APK
flutter build apk --release

# Build app bundle
flutter build appbundle --release
```

### 3. iOS Deployment
```bash
# Build for iOS
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Follow coding standards
4. Write tests for new features
5. Update documentation
6. Submit pull request

## Useful Commands

```bash
# Development
flutter pub get                    # Install dependencies
flutter clean                     # Clean build cache
flutter upgrade                   # Upgrade Flutter

# Code Generation
flutter packages pub run build_runner build    # Generate code
flutter packages pub run build_runner watch    # Watch mode
flutter packages pub run build_runner clean    # Clean generated files

# Testing
flutter test                       # Run tests
flutter test --coverage          # With coverage

# Building
flutter build apk                 # Android APK
flutter build appbundle          # Android App Bundle
flutter build ios                # iOS build

# Analysis
flutter analyze                   # Static analysis
dart format .                     # Format code
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Material 3 Design](https://m3.material.io/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Support

For questions or issues:
1. Check existing documentation
2. Search GitHub issues
3. Create new issue with detailed description
4. Contact the development team