# Build Configuration

This directory contains build-related configuration files.

## Files

### build.dart
- Configures build_runner for code generation
- Used for generating JSON serialization code for data models
- Run with: `flutter packages pub run build_runner build`

## Usage

To generate code for the data models:

```bash
# One-time build
flutter packages pub run build_runner build

# Watch for changes and rebuild automatically
flutter packages pub run build_runner watch

# Clean generated files
flutter packages pub run build_runner clean
```

## Generated Files

The build process will generate `.g.dart` files for:
- `lib/data/models/owner_profile.dart` → `owner_profile.g.dart`
- `lib/data/models/pet_profile.dart` → `pet_profile.g.dart`
- `lib/data/models/match.dart` → `match.g.dart`
- `lib/data/models/message.dart` → `message.g.dart`

These files contain the JSON serialization/deserialization code.