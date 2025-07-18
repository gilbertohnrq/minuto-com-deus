import '../entities/user.dart';
import '../entities/notification_settings.dart';

abstract class UserRepository {
  /// Get user profile by ID
  Future<User> getUserProfile(String userId);
  
  /// Update user profile
  Future<User> updateUserProfile(User user);
  
  /// Update notification settings for a user
  Future<void> updateNotificationSettings(String userId, NotificationSettings settings);
  
  /// Update premium status for a user
  Future<void> updatePremiumStatus(String userId, bool isPremium);
  
  /// Check if user exists
  Future<bool> userExists(String userId);
  
  /// Delete user profile
  Future<void> deleteUserProfile(String userId);
  
  /// Create user profile (used during registration)
  Future<User> createUserProfile(User user);
}