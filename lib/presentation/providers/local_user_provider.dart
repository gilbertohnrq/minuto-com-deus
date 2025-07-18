import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/local_user.dart';
import '../../domain/entities/notification_settings.dart';
import '../../services/local_user_service.dart';

/// Provider for LocalUserService
final localUserServiceProvider = Provider<LocalUserService>((ref) {
  return LocalUserService.instance;
});

/// Provider for the current local user
final currentLocalUserProvider = StateNotifierProvider<LocalUserNotifier, LocalUser?>((ref) {
  final localUserService = ref.watch(localUserServiceProvider);
  return LocalUserNotifier(localUserService);
});

/// Provider for premium status
final isPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(currentLocalUserProvider);
  return user?.isActivePremium ?? false;
});

/// Provider to check if user should see ads
final shouldShowAdsProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  return !isPremium;
});

/// Provider for first time user status
final isFirstTimeUserProvider = Provider<bool>((ref) {
  final localUserService = ref.watch(localUserServiceProvider);
  return localUserService.isFirstTimeUser;
});

class LocalUserNotifier extends StateNotifier<LocalUser?> {
  final LocalUserService _localUserService;
  
  LocalUserNotifier(this._localUserService) : super(null) {
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    await _localUserService.initialize();
    state = _localUserService.currentUser;
  }
  
  /// Update user name
  Future<void> updateUserName(String name) async {
    await _localUserService.updateUserName(name);
    state = _localUserService.currentUser;
  }
  
  /// Update notification settings
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await _localUserService.updateNotificationSettings(settings);
    state = _localUserService.currentUser;
  }
  
  /// Upgrade to premium
  Future<void> upgradeToPremium({DateTime? expirationDate}) async {
    await _localUserService.upgradeToPremium(expirationDate: expirationDate);
    state = _localUserService.currentUser;
  }
  
  /// Downgrade from premium
  Future<void> downgradeFromPremium() async {
    await _localUserService.downgradeFromPremium();
    state = _localUserService.currentUser;
  }
  
  /// Check premium status and update if needed
  Future<void> checkPremiumStatus() async {
    await _localUserService.checkPremiumStatus();
    state = _localUserService.currentUser;
  }
  
  /// Reset user data
  Future<void> resetUserData() async {
    await _localUserService.resetUserData();
    state = _localUserService.currentUser;
  }
  
  /// Get trial days remaining
  int? getTrialDaysRemaining() {
    return _localUserService.getTrialDaysRemaining();
  }
}
