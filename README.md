# PetConnect - A Tinder for Pets 🐾

PetConnect is a Flutter mobile application that connects pet owners with nearby pets for playdates using a swipe-based interface. Think "Tinder for Pets" - helping pets find their perfect playmates!

## Features ✨

### Core Functionality
- **Swipe-based Pet Discovery**: Swipe right to like, left to pass on potential pet matches
- **Real-time Matching**: When two pets like each other, create instant matches
- **Location-based Discovery**: Find pets nearby using GPS and geolocation
- **Real-time Chat**: Message other pet owners when matched
- **Comprehensive Profiles**: Detailed pet and owner profiles with photos

### Authentication
- Email/Password authentication
- Google Sign-In integration
- Apple Sign-In (iOS)
- Secure Firebase Authentication

### Pet Profiles
- Multiple pet photos (up to 6)
- Pet details: name, age, breed, size
- Temperament tags (friendly, energetic, calm, etc.)
- Health information (vaccinated, fixed/neutered)
- Personal bio for each pet

### Discovery & Filtering
- Distance-based filtering (1-100 miles)
- Age range filtering
- Pet size preferences
- Temperament matching

### Safety Features
- Safety tips displayed in chat
- Public meeting recommendations
- Report and block functionality (planned)

## Tech Stack 🛠️

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Riverpod** - State management
- **Flutter ScreenUtil** - Responsive UI

### Backend & Services
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - Image storage
- **Geolocator** - GPS positioning
- **GeoFlutterFire** - Location-based queries

### UI & Animations
- **Card Swiper** - Tinder-style card swiping
- **Cached Network Image** - Optimized image loading
- **Carousel Slider** - Image galleries
- **Lottie** - Animations
- **Material 3** - Modern UI design

## Project Structure 📁

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # App-wide constants, colors, strings
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 theme configuration
│   └── utils/                      # Utility functions
├── data/
│   ├── models/
│   │   ├── owner_profile.dart      # Owner data model
│   │   ├── pet_profile.dart        # Pet data model
│   │   ├── match.dart              # Match data model
│   │   └── message.dart            # Message data model
│   ├── repositories/
│   │   └── owner_repository.dart   # Data access layer
│   └── services/
│       └── firebase_service.dart   # Firebase integration
├── domain/                         # Business logic layer
├── presentation/
│   ├── auth/
│   │   ├── auth_providers.dart     # Authentication state management
│   │   ├── auth_wrapper.dart       # Auth flow controller
│   │   └── login_screen.dart       # Login/signup UI
│   ├── onboarding/
│   │   ├── onboarding_screen.dart  # Welcome screen
│   │   ├── owner_setup_screen.dart # Owner profile setup
│   │   └── pet_setup_screen.dart   # Pet profile setup
│   ├── home/
│   │   ├── home_screen.dart        # Main swipe interface
│   │   ├── home_providers.dart     # Discovery state management
│   │   └── main_navigation.dart    # Bottom navigation
│   ├── matches/
│   │   └── matches_screen.dart     # Matched pets display
│   ├── chat/
│   │   └── chat_list_screen.dart   # Conversations list
│   ├── profile/
│   │   └── profile_screen.dart     # User profile management
│   └── widgets/
│       ├── custom_button.dart      # Reusable button component
│       ├── custom_text_field.dart  # Reusable input component
│       ├── pet_card.dart           # Swipeable pet card
│       └── match_dialog.dart       # Match celebration modal
└── main.dart                       # App entry point
```

## Setup Instructions 🚀

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- Firebase project setup
- iOS/Android development environment

### Firebase Setup
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - Authentication (Email/Password, Google, Apple)
   - Cloud Firestore
   - Firebase Storage
3. Download configuration files:
   - `google-services.json` for Android (`android/app/`)
   - `GoogleService-Info.plist` for iOS (`ios/Runner/`)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd pet_con
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (for JSON serialization):
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Key Features Implementation 🔧

### Swipe Mechanism
- Uses `card_swiper` package for smooth card animations
- Implements like/pass actions with visual feedback
- Stores swipe history to prevent duplicate cards

### Real-time Matching
- Monitors Firestore for mutual likes
- Creates match documents when both users like each other
- Triggers match celebration UI

### Location Services
- Uses `geolocator` for current position
- Implements distance-based filtering
- Stores GeoPoints in Firestore for proximity queries

### State Management
- Riverpod for reactive state management
- Separate providers for different app features
- Clean separation of UI and business logic

## Security & Privacy 🔒

- All user data encrypted in transit and at rest
- Location data anonymized and used only for matching
- Privacy-first approach with minimal data collection
- Secure Firebase Security Rules implementation

## Future Enhancements 🚀

### Planned Features
- **Super Treat**: Premium super-like feature
- **Boost**: Increase profile visibility
- **Advanced Filters**: Breed-specific, activity level matching
- **Pet Services Integration**: Groomers, veterinarians, pet stores
- **Video Profiles**: Short video introductions
- **Group Playdates**: Multi-pet meetups
- **Pet Events**: Local pet events and meetups

### Technical Improvements
- Offline support with local data caching
- Push notifications for matches and messages
- Advanced image compression and caching
- Machine learning for better matching algorithms
- Integration with pet health records

## Contributing 🤝

We welcome contributions! Please read our contributing guidelines and submit pull requests for any improvements.

### Development Guidelines
- Follow Flutter/Dart style guide
- Use Riverpod for state management
- Implement responsive design with ScreenUtil
- Add comprehensive documentation
- Write unit and widget tests

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Support 💬

For support, email support@petconnect.app or create an issue in this repository.

---

**Made with ❤️ for pet lovers everywhere!** 🐕🐱

*PetConnect - Where every pet finds their perfect playmate* 🎾
