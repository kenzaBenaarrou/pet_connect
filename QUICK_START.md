# 🎯 Quick Start: NestJS Backend + Firebase Chat

## What's Been Set Up

Your Flutter app now has a **hybrid architecture**:
- ✅ **NestJS Backend** for API calls (users, pets, matches)
- ✅ **Firebase** for real-time chat only
- ✅ **Clean separation** between the two systems

---

## 📁 New Files

```
lib/
├── core/config/
│   └── api_config.dart              # Backend URL configuration
├── data/
│   ├── services/
│   │   ├── api_service.dart         # HTTP client for NestJS
│   │   └── chat_service.dart        # Firebase chat (real-time)
│   ├── repositories/
│   │   ├── owner_api_repository.dart  # User API operations
│   │   ├── pet_api_repository.dart    # Pet API operations
│   │   └── match_api_repository.dart  # Match API operations
│   └── providers/
│       └── pet_providers.dart       # Example Riverpod providers
└── presentation/examples/
    └── backend_integration_example.dart  # Usage examples

BACKEND_INTEGRATION.md              # Full documentation
```

---

## 🚀 How to Use

### 1. Configure Your Backend URL

**Edit:** `lib/core/config/api_config.dart`

```dart
// For local development on emulator
static const String localUrl = 'http://10.0.2.2:3000/api';  // Android
static const String localUrl = 'http://localhost:3000/api';  // iOS

// For physical device
static const String localUrl = 'http://YOUR_IP:3000/api';

// Change environment
static const Environment environment = Environment.local;
```

### 2. Use API Repositories

```dart
// Get user's pets from NestJS backend
final petRepo = ref.read(petApiRepositoryProvider);
final pets = await petRepo.getPetsByOwner(userId);

// Create a new pet
final pet = PetProfile(...);
final createdPet = await petRepo.createPet(pet);

// Get discovery pets
final discoveryPets = await petRepo.getDiscoveryPets(
  limit: 10,
  minAge: 6,
  maxAge: 60,
);
```

### 3. Use Chat Service (Firebase)

```dart
// Send message
final chatService = ref.read(chatServiceProvider);
await chatService.sendMessage(
  matchId: matchId,
  senderId: currentUserId,
  senderName: userName,
  text: 'Hello!',
);

// Listen to messages (real-time)
chatService.getMessages(matchId).listen((messages) {
  // Update UI with messages
});
```

---

## 🔄 Migration Path

### Current: All Firebase
```dart
// OLD: Direct Firestore
FirebaseFirestore.instance
  .collection('pets')
  .doc(petId)
  .get();
```

### Future: Hybrid (Recommended)
```dart
// NEW: NestJS API for data
final petRepo = ref.read(petApiRepositoryProvider);
final pet = await petRepo.getPet(petId);

// Firebase only for chat
final chatService = ref.read(chatServiceProvider);
chatService.getMessages(matchId).listen(...);
```

---

## 🧪 Test the Setup

### Test Backend Connection

```dart
try {
  final ownerRepo = ref.read(ownerApiRepositoryProvider);
  final profile = await ownerRepo.getCurrentProfile();
  print('✅ Backend connected: ${profile.name}');
} catch (e) {
  print('❌ Backend error: $e');
}
```

### Test Chat

```dart
final chatService = ref.read(chatServiceProvider);
await chatService.sendMessage(
  matchId: 'test',
  senderId: 'user1',
  senderName: 'Test',
  text: 'Hello',
);
```

---

## 🔐 Authentication

All API calls automatically include Firebase auth token:

1. User signs in with Firebase
2. Token sent in header: `Authorization: Bearer <token>`
3. NestJS validates token
4. Returns data

---

## 📡 NestJS Endpoints You Need

### Users
```
GET    /api/users/me
GET    /api/users/:id
POST   /api/users
PUT    /api/users/:id
DELETE /api/users/:id
```

### Pets
```
GET    /api/pets/:id
GET    /api/pets/owner/:ownerId
POST   /api/pets
PUT    /api/pets/:id
DELETE /api/pets/:id
GET    /api/pets/discovery?limit=10&minAge=6&maxAge=60
```

### Matches
```
POST   /api/swipes
GET    /api/matches
GET    /api/matches/:id
GET    /api/matches/check/:petId
DELETE /api/matches/:id
```

---

## 🐛 Troubleshooting

### "Connection refused"
- ✅ Backend is running
- ✅ Correct URL in `api_config.dart`
- ✅ Use `10.0.2.2` for Android emulator
- ✅ Use your local IP for physical devices

### "Unauthorized" (401)
- ✅ User is signed in to Firebase
- ✅ Token is being sent
- ✅ NestJS validates Firebase tokens

### Messages not working
- ✅ Firebase initialized
- ✅ Firestore rules allow access
- ✅ Internet connection

---

## 📚 Documentation

- **BACKEND_INTEGRATION.md** - Complete guide
- **backend_integration_example.dart** - Code examples
- **pet_providers.dart** - Riverpod provider examples

---

## ✅ Next Steps

1. **Setup NestJS backend** with the endpoints above
2. **Test API connection** from Flutter
3. **Migrate features gradually**:
   - Start with user profiles
   - Then pets
   - Then matches
   - Keep chat on Firebase
4. **Deploy** to production

---

## 💡 Tips

- Keep both Firebase and API working during migration
- Use try-catch to fallback to Firebase if API fails
- Chat stays on Firebase (best for real-time)
- You can migrate storage to your backend or keep Firebase Storage

---

**You're all set!** 🎉

Your app can now talk to NestJS backend while keeping Firebase for chat.
