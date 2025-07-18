import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/local_user.dart';
import '../domain/entities/notification_settings.dart';
import '../domain/entities/reading_streak.dart';

class LocalUserService {
  static const String _userKey = 'local_user';
  static const String _hasOpenedAppKey = 'has_opened_app';
  
  static LocalUserService? _instance;
  static LocalUserService get instance => _instance ??= LocalUserService._();
  
  LocalUserService._();
  
  SharedPreferences? _prefs;
  LocalUser? _currentUser;
  
  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadOrCreateUser();
  }
  
  /// Get the current local user
  LocalUser? get currentUser => _currentUser;
  
  /// Get the current local user (async version)
  Future<LocalUser?> getUser() async {
    if (_currentUser == null) {
      await _loadOrCreateUser();
    }
    return _currentUser;
  }
  
  /// Check if user has premium access
  bool get hasPremiumAccess => _currentUser?.isActivePremium ?? false;
  
  /// Check if this is the first time opening the app
  bool get isFirstTimeUser => !(_prefs?.getBool(_hasOpenedAppKey) ?? false);
  
  /// Load existing user or create a new one
  Future<void> _loadOrCreateUser() async {
    final userJson = _prefs?.getString(_userKey);
    
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _currentUser = LocalUser.fromJson(userMap);
      } catch (e) {
        // If there's an error loading, create a new user
        await _createNewUser();
      }
    } else {
      await _createNewUser();
    }
    
    // Mark that the app has been opened
    await _prefs?.setBool(_hasOpenedAppKey, true);
  }
  
  /// Create a new local user
  Future<void> _createNewUser() async {
    const uuid = Uuid();
    _currentUser = LocalUser(
      id: uuid.v4(),
      isPremium: false,
      notificationSettings: NotificationSettings.defaultSettings(),
      createdAt: DateTime.now(),
      readingStreak: ReadingStreak.empty(),
    );
    
    await _saveUser();
  }
  
  /// Save the current user to storage
  Future<void> _saveUser() async {
    if (_currentUser != null && _prefs != null) {
      final userJson = jsonEncode(_currentUser!.toJson());
      await _prefs!.setString(_userKey, userJson);
    }
  }
  
  /// Update user with new data
  Future<void> updateUser(LocalUser user) async {
    _currentUser = user;
    await _saveUser();
  }
  
  /// Update user name
  Future<void> updateUserName(String name) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name);
      await _saveUser();
    }
  }
  
  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(notificationSettings: settings);
      await _saveUser();
    }
  }
  
  /// Upgrade to premium
  Future<void> upgradeToPremium({DateTime? expirationDate}) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isPremium: true,
        premiumExpirationDate: expirationDate,
      );
      await _saveUser();
    }
  }
  
  /// Downgrade from premium (when subscription expires)
  Future<void> downgradeFromPremium() async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isPremium: false,
        premiumExpirationDate: null,
      );
      await _saveUser();
    }
  }
  
  /// Check and update premium status based on expiration
  Future<void> checkPremiumStatus() async {
    if (_currentUser != null && 
        _currentUser!.isPremium && 
        _currentUser!.premiumExpirationDate != null &&
        DateTime.now().isAfter(_currentUser!.premiumExpirationDate!)) {
      await downgradeFromPremium();
    }
  }
  
  /// Reset user data (for testing or fresh start)
  Future<void> resetUserData() async {
    await _prefs?.remove(_userKey);
    await _prefs?.remove(_hasOpenedAppKey);
    await _createNewUser();
  }
  
  /// Get trial period remaining days (if applicable)
  int? getTrialDaysRemaining() {
    if (_currentUser?.premiumExpirationDate == null) return null;
    
    final now = DateTime.now();
    final expiration = _currentUser!.premiumExpirationDate!;
    
    if (now.isAfter(expiration)) return 0;
    
    return expiration.difference(now).inDays;
  }
}
