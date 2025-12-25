# 🚀 NestJS Authentication - Quick Reference

## Authentication Flow Summary

```
Flutter App                    NestJS Backend              Firebase
    │                               │                          │
    │  POST /auth/login             │                          │
    │  {email, password}            │                          │
    ├──────────────────────────────>│                          │
    │                               │  Verify credentials      │
    │                               │  Generate JWT            │
    │                               │  Create custom token     │
    │                               ├─────────────────────────>│
    │                               │                          │
    │  {user, access_token,         │                          │
    │   firebase_token}             │                          │
    │<──────────────────────────────┤                          │
    │                               │                          │
    │  Store JWT in secure storage  │                          │
    │  signInWithCustomToken()      │                          │
    ├────────────────────────────────────────────────────────>│
    │                               │                          │
    │  Authenticated!               │                          │
    │<────────────────────────────────────────────────────────┤
```

## Flutter Code Changes

### ❌ Old Way (Removed)
```dart
// Direct Firebase authentication
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### ✅ New Way
```dart
// NestJS backend authentication
await ref.read(authProvider.notifier).signInWithEmail(email, password);
```

## Key Changes

| Component | Old | New |
|-----------|-----|-----|
| User Model | `firebase_auth.User` | `UserModel` (custom) |
| Auth Method | Firebase SDK directly | NestJS API + Firebase custom token |
| Token Storage | Firebase manages | `flutter_secure_storage` |
| API Authorization | Firebase ID token | JWT from NestJS |
| Sign Up Parameters | `(email, password)` | `(name, email, password)` ⚠️ |

## New Files

```
lib/
├── data/
│   ├── models/
│   │   └── user_model.dart              ✨ NEW
│   ├── repositories/
│   │   └── auth_api_repository.dart     ✨ NEW
│   └── services/
│       └── secure_storage_service.dart  ✨ NEW
└── presentation/
    └── examples/
        └── auth_screen_example.dart     ✨ NEW
```

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Generate JSON code
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run
```

## API Endpoints (NestJS)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | No | Create account |
| POST | `/auth/login` | No | Login |
| GET | `/auth/me` | Yes | Get profile |
| GET | `/auth/refresh-firebase-token` | Yes | Refresh Firebase token |

## Common Patterns

### Login
```dart
try {
  await ref.read(authProvider.notifier).signInWithEmail(
    'user@example.com',
    'password',
  );
} catch (e) {
  print('Error: $e');
}
```

### Sign Up (⚠️ NOTE: Added 'name' parameter)
```dart
try {
  await ref.read(authProvider.notifier).signUpWithEmail(
    'John Doe',        // ← NEW: name parameter
    'user@example.com',
    'password',
  );
} catch (e) {
  print('Error: $e');
}
```

### Get User
```dart
final user = ref.watch(currentUserProvider);
if (user != null) {
  print(user.name);
  print(user.email);
  print(user.firebaseUid);
}
```

### Sign Out
```dart
await ref.read(authProvider.notifier).signOut();
```

## Security

### Stored Securely
- JWT token (NestJS)
- Firebase custom token
- User ID, email, name

### Platform Security
- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences
- **Web/Desktop**: Secure storage fallback

## Troubleshooting

| Error | Solution |
|-------|----------|
| "No authentication token found" | User not logged in, redirect to login |
| "Failed to sign in with custom token" | Firebase token expired, refresh it |
| "Login error" | Check NestJS backend is running |
| JSON errors | Run `build_runner build` |

## Documentation Files

- 📘 `NESTJS_AUTH_MIGRATION_COMPLETE.md` - Complete migration guide
- 📘 `NESTJS_BACKEND_IMPLEMENTATION.md` - Backend implementation
- 📘 `ENV_SETUP_COMPLETE.md` - Environment setup
- 📘 This file - Quick reference

## Next Steps

1. ✅ Flutter migration complete
2. ⏳ Implement NestJS endpoints (see `NESTJS_BACKEND_IMPLEMENTATION.md`)
3. ⏳ Update existing login/signup screens with new signatures
4. ⏳ Test end-to-end authentication flow

---

**Important**: Your `signUpWithEmail()` now requires a `name` parameter as the first argument!

**Old**: `signUpWithEmail(email, password)`
**New**: `signUpWithEmail(name, email, password)`
