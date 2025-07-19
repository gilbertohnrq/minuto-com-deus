# Implementation Plan

- [x] 1. Set up project structure and core dependencies
  - Create Flutter project with proper directory structure (lib/core, lib/data, lib/domain, lib/presentation, lib/services)
  - Configure pubspec.yaml with required dependencies: firebase_core, firebase_auth, firebase_messaging, flutter_local_notifications, flutter_riverpod, riverpod_annotation, intl, google_sign_in, cloud_firestore, google_mobile_ads
  - Set up main.dart with Firebase initialization and Riverpod configuration
  - _Requirements: 7.1, 7.2, 7.4_

- [x] 2. Implement core domain entities and utilities
  - [x] 2.1 Create domain entities
    - Write Devotional entity with id, date, verse, message fields
    - Write User entity with id, email, name, isPremium, notificationSettings, createdAt fields
    - Write NotificationSettings entity with enabled, scheduledTime, selectedDays fields
    - _Requirements: 7.2, 5.1_

  - [x] 2.2 Create core utilities and constants
    - Implement DateUtils with Brazilian date formatting and utility functions
    - Create AppException hierarchy with custom exceptions
    - Add AppConstants for app-wide configuration values
    - _Requirements: 3.4, 4.5, 7.2_

- [x] 3. Set up basic app structure and navigation
  - [x] 3.1 Create basic authentication provider
    - Implement authStateProvider with Firebase Auth integration
    - Add currentUserProvider and isAuthenticatedProvider
    - Set up basic auth state management with Riverpod
    - _Requirements: 4.1, 7.5_

  - [x] 3.2 Create basic notification service
    - Implement NotificationService with local notifications setup
    - Add Firebase Cloud Messaging initialization
    - Implement daily notification scheduling at 8:00 AM
    - _Requirements: 2.1, 2.2, 2.4_

  - [x] 3.3 Create basic app structure and routing
    - Implement App widget with theme configuration
    - Add authentication-based routing between login and home screens
    - Create basic LoginScreen and HomeScreen placeholders
    - _Requirements: 4.1, 8.1, 8.2_

- [x] 4. Create sample devotional data and local data handling
  - [x] 4.1 Create sample devotional JSON data
    - Create assets/data/devocionais.json with sample devotional entries
    - Structure JSON with data, versiculo, mensagem fields
    - Add at least 30 days of sample devotional content
    - _Requirements: 3.1, 3.2_

  - [x] 4.2 Implement devotional data models and repository interfaces
    - Create DevotionalModel with fromJson factory and toEntity method
    - Define DevotionalRepository interface for data access
    - Create DevotionalLocalDataSource for JSON file loading
    - _Requirements: 3.2, 7.2_

  - [x] 4.3 Implement devotional repository with local data source
    - Create DevotionalRepositoryImpl with local data source integration
    - Add date matching logic to find devotional for specific date
    - Implement caching mechanism and error handling for missing data
    - _Requirements: 1.3, 3.1, 3.3, 3.4_

- [x] 5. Implement Firebase authentication system
  - [x] 5.1 Create authentication service and repository
    - Create AuthService with email/password and Google Sign-In methods
    - Implement AuthRepository with Firebase Auth integration
    - Add proper error handling for authentication failures
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.6_

  - [x] 5.2 Create user data models and Firestore integration
    - Create UserModel with fromFirestore/toFirestore methods
    - Implement UserRemoteDataSource for Firestore operations
    - Add user profile creation after successful registration
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [x] 5.3 Implement user repository with Firestore
    - Create UserRepositoryImpl with Firestore integration
    - Add offline caching for user profile data
    - Implement CRUD operations for user profiles
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 6. Create functional authentication UI
  - [x] 6.1 Implement complete login screen
    - Replace placeholder LoginScreen with functional form
    - Add email/password validation and Google Sign-In button
    - Implement loading states and error message display
    - _Requirements: 4.1, 4.2, 4.3, 8.1, 8.5_

  - [x] 6.2 Create registration screen
    - Implement RegisterScreen with email/password and name fields
    - Add form validation and password confirmation
    - Implement navigation between login and registration screens
    - _Requirements: 4.1, 4.2, 4.3, 8.1, 8.5_

- [-] 7. Implement functional home screen with devotional display
  - [x] 7.1 Create devotional providers and state management
    - Implement devotional providers using Riverpod
    - Add today's devotional loading with error handling
    - Create state management for devotional content
    - _Requirements: 1.1, 1.2, 1.3, 7.5_

  - [x] 7.2 Replace placeholder home screen with functional UI
    - Create responsive devotional card layout
    - Display date, biblical verse, and reflection text with proper typography
    - Add pull-to-refresh functionality and fallback message for missing dates
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 8.1, 8.2, 8.3, 8.4_

- [ ] 8. Create settings screen and user profile management
  - [x] 8.1 Implement settings screen
    - Create SettingsScreen with user profile display
    - Add logout functionality with confirmation dialog
    - Create placeholder for notification time preferences
    - _Requirements: 4.6, 8.1, 8.5_

  - [x] 8.2 Add navigation between screens
    - Implement proper navigation between home and settings screens
    - Add navigation drawer or bottom navigation
    - Ensure proper route management and deep linking
    - _Requirements: 2.3, 4.1, 4.2_

- [x] 9. Implement advertisement system for freemium model
  - [x] 9.1 Create ad service
    - Write AdService with Google Mobile Ads integration
    - Implement banner and interstitial ad loading
    - Add proper ad disposal and error handling
    - _Requirements: 6.1, 6.2, 6.4_

  - [x] 9.2 Integrate ads into UI
    - Add banner ads to home screen for non-premium users
    - Implement ad visibility logic based on user premium status
    - Ensure ads don't interfere with devotional content readability
    - _Requirements: 6.1, 6.2, 6.3, 8.1, 8.4_

- [x] 10. Create reusable UI components and improve UX
  - [x] 10.1 Implement devotional card widget
    - Create DevotionalCard widget with consistent styling
    - Add proper text formatting for verse and message content
    - Implement responsive design for different screen sizes
    - _Requirements: 1.2, 1.4, 8.1, 8.2, 8.3_

  - [x] 10.2 Create common UI widgets
    - Write LoadingWidget for consistent loading states
    - Create ErrorWidget with retry functionality
    - Implement custom form field widgets with validation
    - _Requirements: 8.1, 8.5_

- [ ] 11. Implement reflection system for devotionals
  - [ ] 11.1 Create reflection domain entities and repositories
    - Create Reflection entity with id, devotionalId, userId, content, timestamps
    - Define ReflectionRepository interface for CRUD operations
    - Implement ReflectionLocalDataSource for local storage
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ] 11.2 Create reflection service and data persistence
    - Implement ReflectionService with save, get, and update methods
    - Add local storage using SharedPreferences or SQLite for reflections
    - Create ReflectionRepositoryImpl with local data source integration
    - _Requirements: 6.2, 6.3, 6.5_

  - [ ] 11.3 Add reflection UI to devotional display
    - Add text input field to devotional card for user reflections
    - Implement save/edit functionality with loading states
    - Display existing reflections when available
    - _Requirements: 6.1, 6.4, 10.6_

- [ ] 12. Implement reading streak system with animations
  - [ ] 12.1 Create reading streak domain and data layer
    - Create ReadingStreak entity with currentStreak, longestStreak, dates
    - Define ReadingStreakRepository interface
    - Implement ReadingStreakService with increment and reset logic
    - _Requirements: 7.1, 7.3, 7.4_

  - [ ] 12.2 Integrate streak tracking with reflection submission
    - Connect reflection saving to streak increment logic
    - Implement daily streak validation and reset for missed days
    - Add streak milestone detection (7, 30, 100 days)
    - _Requirements: 7.1, 7.3, 7.5_

  - [ ] 12.3 Create streak display and celebration animations
    - Add streak counter display to home screen
    - Implement animated celebration when streak increases
    - Create special milestone animations for achievement unlocks
    - _Requirements: 7.2, 7.4, 7.5, 10.6_

- [ ] 13. Update advertisement system for post-reflection display
  - [ ] 13.1 Modify ad service for interstitial-only approach
    - Remove banner ad functionality from AdService
    - Focus on interstitial ads triggered after reflection submission
    - Update ad loading and display logic
    - _Requirements: 8.1, 8.3_

  - [ ] 13.2 Integrate ads with reflection workflow
    - Show interstitial ad after user submits reflection (free users only)
    - Ensure ads don't interrupt devotional reading experience
    - Add proper error handling for ad loading failures
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 14. Add comprehensive input validation
  - [ ] 14.1 Create validation utilities
    - Create Validators class for email, password, name, and reflection validation
    - Implement form validation with proper error messages
    - Add input sanitization and security measures
    - _Requirements: 4.3, 9.2_

- [ ] 15. Configure Firebase and build setup
  - [ ] 15.1 Set up Firebase configuration
    - Add google-services.json for Android configuration
    - Configure Firebase Authentication providers
    - Set up Firestore security rules for user data
    - _Requirements: 2.1, 4.1, 5.4_

  - [ ] 15.2 Configure build and deployment
    - Set up Android build configuration with proper signing
    - Configure app permissions for notifications and internet
    - Test release build with flutter build apk --release
    - _Requirements: 7.4_

- [ ] 16. Final integration and manual testing
  - [ ] 16.1 Manual integration testing
    - Test complete authentication flow from login to home screen
    - Verify notification scheduling and handling works correctly
    - Test offline functionality with local JSON data
    - Test reflection and streak system end-to-end
    - _Requirements: 1.1, 2.3, 3.1, 4.1, 6.1, 7.1_

  - [ ] 16.2 Final polish and user experience testing
    - Test app startup flow with authentication check
    - Verify premium/free user experience differences with new ad placement
    - Test reflection submission and streak animations
    - Add final UI polish and accessibility improvements
    - _Requirements: 4.1, 8.1, 8.4, 10.6_