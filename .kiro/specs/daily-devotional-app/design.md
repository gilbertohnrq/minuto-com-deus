# Design Document

## Overview

The Daily Devotional App is a Flutter mobile application that delivers daily spiritual messages through push notifications. The app follows a clean architecture pattern with clear separation of concerns, utilizing Riverpod for state management and Firebase services for authentication, user management, and push notifications.

The application is designed to be scalable, maintainable, and user-friendly, with a focus on offline-first functionality for the core devotional content while leveraging cloud services for user management and premium features.

## Architecture

### High-Level Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────┐
│           Presentation Layer        │
│  (Screens, Widgets, ViewModels)     │
├─────────────────────────────────────┤
│           Business Layer            │
│     (Services, Use Cases)           │
├─────────────────────────────────────┤
│             Data Layer              │
│  (Repositories, Data Sources)       │
├─────────────────────────────────────┤
│          External Services          │
│  (Firebase, Local Storage, APIs)    │
└─────────────────────────────────────┘
```

### State Management

The app uses **Riverpod** for state management:

- **Providers**: Define state and business logic using various provider types (StateNotifier, AsyncNotifier, etc.)
- **Consumers**: Use ConsumerWidget and Consumer to listen to state changes and rebuild UI
- **Code Generation**: Leverage riverpod_generator for type-safe, auto-generated providers

### Directory Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Main app configuration
│   └── routes.dart                 # Route definitions
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── notification_constants.dart
│   ├── errors/
│   │   └── exceptions.dart         # Custom exceptions
│   └── utils/
│       ├── date_utils.dart         # Date utility functions
│       └── validators.dart         # Input validation
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── devotional_local_datasource.dart
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart
│   │       └── user_remote_datasource.dart
│   ├── models/
│   │   ├── devotional_model.dart
│   │   ├── user_model.dart
│   │   └── notification_model.dart
│   └── repositories/
│       ├── devotional_repository_impl.dart
│       ├── auth_repository_impl.dart
│       └── user_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── devotional.dart
│   │   ├── user.dart
│   │   └── notification_settings.dart
│   ├── repositories/
│   │   ├── devotional_repository.dart
│   │   ├── auth_repository.dart
│   │   └── user_repository.dart
│   └── usecases/
│       ├── get_daily_devotional.dart
│       ├── authenticate_user.dart
│       └── schedule_notifications.dart
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   └── devotional/
│   │       └── devotional_card.dart
│   └── viewmodels/
│       ├── auth_viewmodel.dart
│       ├── home_viewmodel.dart
│       └── settings_viewmodel.dart
├── services/
│   ├── notification_service.dart
│   ├── auth_service.dart
│   └── ad_service.dart
└── assets/
    └── data/
        └── devocionais.json
```

## Components and Interfaces

### Core Entities

#### Devotional Entity
```dart
class Devotional {
  final String id;
  final DateTime date;
  final String verse;
  final String message;
  final String? imageUrl;
  
  const Devotional({
    required this.id,
    required this.date,
    required this.verse,
    required this.message,
    this.imageUrl,
  });
}
```

#### User Entity
```dart
class User {
  final String id;
  final String email;
  final String? name;
  final bool isPremium;
  final NotificationSettings notificationSettings;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.email,
    this.name,
    required this.isPremium,
    required this.notificationSettings,
    required this.createdAt,
  });
}
```

#### Reflection Entity
```dart
class Reflection {
  final String id;
  final String devotionalId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const Reflection({
    required this.id,
    required this.devotionalId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });
}
```

#### ReadingStreak Entity
```dart
class ReadingStreak {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastReflectionDate;
  final List<DateTime> reflectionDates;
  
  const ReadingStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReflectionDate,
    required this.reflectionDates,
  });
  
  bool get isStreakActive {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastDate = DateTime(lastReflectionDate.year, lastReflectionDate.month, lastReflectionDate.day);
    
    return lastDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day)) ||
           lastDate.isAtSameMomentAs(yesterday);
  }
}
```

#### NotificationSettings Entity
```dart
class NotificationSettings {
  final bool enabled;
  final TimeOfDay scheduledTime;
  final List<int> selectedDays; // 1-7 for Monday-Sunday
  
  const NotificationSettings({
    required this.enabled,
    required this.scheduledTime,
    required this.selectedDays,
  });
}
```

### Repository Interfaces

#### DevotionalRepository
```dart
abstract class DevotionalRepository {
  Future<Devotional?> getDailyDevotional(DateTime date);
  Future<List<Devotional>> getDevotionalHistory(int limit);
  Future<void> cacheDevotionals(List<Devotional> devotionals);
}
```

#### AuthRepository
```dart
abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signInWithEmail(String email, String password);
  Future<User> signInWithGoogle();
  Future<User> registerWithEmail(String email, String password, String? name);
  Future<void> signOut();
  Stream<User?> authStateChanges();
}
```

#### UserRepository
```dart
abstract class UserRepository {
  Future<User> getUserProfile(String userId);
  Future<void> updateUserProfile(User user);
  Future<void> updateNotificationSettings(String userId, NotificationSettings settings);
  Future<void> updatePremiumStatus(String userId, bool isPremium);
}
```

#### ReflectionRepository
```dart
abstract class ReflectionRepository {
  Future<void> saveReflection(Reflection reflection);
  Future<Reflection?> getReflection(String devotionalId, String userId);
  Future<List<Reflection>> getUserReflections(String userId, {int? limit});
  Future<void> updateReflection(Reflection reflection);
  Future<void> deleteReflection(String reflectionId);
}
```

#### ReadingStreakRepository
```dart
abstract class ReadingStreakRepository {
  Future<ReadingStreak> getUserStreak(String userId);
  Future<void> updateStreak(ReadingStreak streak);
  Future<void> incrementStreak(String userId, DateTime reflectionDate);
  Future<void> resetStreak(String userId);
}
```

### Services

#### NotificationService
```dart
class NotificationService {
  Future<void> initialize();
  Future<void> requestPermissions();
  Future<void> scheduleDailyNotification(TimeOfDay time);
  Future<void> cancelAllNotifications();
  Future<void> handleNotificationTap(String payload);
  Future<String?> getFCMToken();
}
```

#### AuthService
```dart
class AuthService {
  Future<void> initialize();
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> createUserWithEmail(String email, String password);
  Future<void> signOut();
  Stream<firebase_auth.User?> authStateChanges();
}
```

#### AdService
```dart
class AdService {
  Future<void> initialize();
  Future<void> loadInterstitialAd();
  Future<void> showInterstitialAd();
  void dispose();
  bool get isInterstitialAdLoaded;
}
```

#### ReflectionService
```dart
class ReflectionService {
  Future<void> saveReflection(String devotionalId, String content);
  Future<Reflection?> getReflection(String devotionalId);
  Future<void> updateReflection(String reflectionId, String content);
  Stream<List<Reflection>> getUserReflectionsStream();
}
```

#### ReadingStreakService
```dart
class ReadingStreakService {
  Future<ReadingStreak> getCurrentStreak();
  Future<void> recordReflection(DateTime date);
  Future<bool> checkStreakMilestone(int newStreak);
  Stream<ReadingStreak> streakStream();
}
```

### ViewModels

#### HomeViewModel
```dart
class HomeViewModel extends ChangeNotifier {
  final DevotionalRepository _devotionalRepository;
  final UserRepository _userRepository;
  final ReflectionService _reflectionService;
  final ReadingStreakService _streakService;
  final AdService _adService;
  
  Devotional? _todayDevotional;
  User? _currentUser;
  Reflection? _todayReflection;
  ReadingStreak? _currentStreak;
  bool _isLoading = false;
  bool _isSavingReflection = false;
  String? _errorMessage;
  
  // Getters
  Devotional? get todayDevotional => _todayDevotional;
  User? get currentUser => _currentUser;
  Reflection? get todayReflection => _todayReflection;
  ReadingStreak? get currentStreak => _currentStreak;
  bool get isLoading => _isLoading;
  bool get isSavingReflection => _isSavingReflection;
  String? get errorMessage => _errorMessage;
  bool get shouldShowAds => _currentUser?.isPremium != true;
  
  // Methods
  Future<void> loadTodayDevotional();
  Future<void> loadTodayReflection();
  Future<void> loadCurrentStreak();
  Future<void> saveReflection(String content);
  Future<void> refreshDevotional();
  void clearError();
}
```

#### AuthViewModel
```dart
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  // Methods
  Future<void> signInWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> registerWithEmail(String email, String password, String? name);
  Future<void> signOut();
  void clearError();
}
```

## Data Models

### Local Data Models

#### DevotionalModel
```dart
class DevotionalModel {
  final String data;
  final String versiculo;
  final String mensagem;
  
  DevotionalModel({
    required this.data,
    required this.versiculo,
    required this.mensagem,
  });
  
  factory DevotionalModel.fromJson(Map<String, dynamic> json) {
    return DevotionalModel(
      data: json['data'],
      versiculo: json['versiculo'],
      mensagem: json['mensagem'],
    );
  }
  
  Devotional toEntity() {
    return Devotional(
      id: data,
      date: DateTime.parse(data),
      verse: versiculo,
      message: mensagem,
    );
  }
}
```

### Firebase Data Models

#### UserModel (Firestore)
```dart
class UserModel {
  final String id;
  final String email;
  final String? name;
  final bool isPremium;
  final Map<String, dynamic> notificationSettings;
  final Timestamp createdAt;
  
  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.isPremium,
    required this.notificationSettings,
    required this.createdAt,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'],
      name: data['name'],
      isPremium: data['isPremium'] ?? false,
      notificationSettings: data['notificationSettings'] ?? {},
      createdAt: data['createdAt'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'isPremium': isPremium,
      'notificationSettings': notificationSettings,
      'createdAt': createdAt,
    };
  }
  
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      isPremium: isPremium,
      notificationSettings: NotificationSettings.fromMap(notificationSettings),
      createdAt: createdAt.toDate(),
    );
  }
}
```

## Error Handling

### Custom Exceptions

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message, 'network_error');
}

class AuthException extends AppException {
  const AuthException(String message, String code) : super(message, code);
}

class DevotionalNotFoundException extends AppException {
  const DevotionalNotFoundException(String date) 
    : super('Devocional não encontrado para a data: $date', 'devotional_not_found');
}
```

### Error Handling Strategy

1. **Repository Level**: Catch and transform platform-specific exceptions into domain exceptions
2. **ViewModel Level**: Handle exceptions and update UI state accordingly
3. **UI Level**: Display user-friendly error messages and provide retry mechanisms

### Error States in ViewModels

```dart
class ErrorState {
  final String message;
  final String? code;
  final bool isRetryable;
  
  const ErrorState({
    required this.message,
    this.code,
    this.isRetryable = true,
  });
}
```

## Testing Strategy

### Unit Testing

1. **Repository Tests**: Mock data sources and test business logic
2. **ViewModel Tests**: Test state management and user interactions
3. **Service Tests**: Test Firebase integration and notification handling
4. **Utility Tests**: Test date formatting, validation, and helper functions

### Integration Testing

1. **Authentication Flow**: Test complete sign-in/sign-up processes
2. **Notification Flow**: Test notification scheduling and handling
3. **Data Persistence**: Test local storage and Firebase synchronization

### Widget Testing

1. **Screen Tests**: Test UI rendering and user interactions
2. **Widget Tests**: Test individual components and their behavior
3. **Navigation Tests**: Test route transitions and deep linking

### Test Structure

```
test/
├── unit/
│   ├── repositories/
│   ├── viewmodels/
│   ├── services/
│   └── utils/
├── integration/
│   ├── auth_flow_test.dart
│   ├── notification_flow_test.dart
│   └── data_sync_test.dart
└── widget/
    ├── screens/
    ├── widgets/
    └── navigation/
```

### Testing Tools

- **flutter_test**: Core testing framework
- **mockito**: Mocking dependencies
- **firebase_auth_mocks**: Mocking Firebase Auth
- **cloud_firestore_mocks**: Mocking Firestore
- **integration_test**: End-to-end testing

## Firebase Configuration

### Authentication Setup

```dart
// Firebase Auth configuration
class FirebaseAuthConfig {
  static const List<String> scopes = [
    'email',
    'profile',
  ];
  
  static const Map<String, String> customParameters = {
    'login_hint': 'user@example.com',
  };
}
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public devotional content (if needed for future features)
    match /devotionals/{devotionalId} {
      allow read: if request.auth != null;
    }
  }
}
```

### Cloud Messaging Setup

```dart
// FCM configuration
class FCMConfig {
  static const String vapidKey = "YOUR_VAPID_KEY";
  static const String defaultNotificationChannelId = "devotional_notifications";
  static const String defaultNotificationChannelName = "Daily Devotionals";
  static const String defaultNotificationChannelDescription = 
    "Notifications for daily devotional messages";
}
```

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load devotional content on-demand
2. **Caching**: Cache frequently accessed data locally
3. **Image Optimization**: Compress and cache devotional images
4. **Background Processing**: Handle notifications in background isolates
5. **Memory Management**: Dispose resources properly in ViewModels

### Caching Strategy

```dart
class CacheManager {
  static const Duration cacheExpiry = Duration(hours: 24);
  
  Future<void> cacheDevotional(Devotional devotional);
  Future<Devotional?> getCachedDevotional(DateTime date);
  Future<void> clearExpiredCache();
}
```

### Resource Management

```dart
abstract class DisposableViewModel extends ChangeNotifier {
  bool _disposed = false;
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
```

This design provides a solid foundation for building a scalable, maintainable daily devotional app with clean architecture principles, proper error handling, and comprehensive testing strategies.