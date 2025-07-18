import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'ad_service.dart';
import 'local_user_service.dart';
import '../presentation/widgets/common/premium_popup.dart';

class AppLaunchService {
  static AppLaunchService? _instance;
  static AppLaunchService get instance => _instance ??= AppLaunchService._();
  
  AppLaunchService._();

  bool _hasShownLaunchAd = false;

  /// Show launch interstitial ad and premium popup for non-premium users
  Future<void> showLaunchExperience(BuildContext context) async {
    if (_hasShownLaunchAd) return;

    try {
      // Check if user is premium
      final localUserService = LocalUserService.instance;
      final currentUser = localUserService.currentUser;
      
      if (currentUser?.isActivePremium == true) {
        if (kDebugMode) {
          print('AppLaunchService: User is premium, skipping ads');
        }
        return;
      }

      final adService = AdService.instance;
      
      // Show interstitial ad if available
      if (adService.isInterstitialAdLoaded) {
        if (kDebugMode) {
          print('AppLaunchService: Showing launch interstitial ad');
        }
        
        await adService.showInterstitialAd();
        _hasShownLaunchAd = true;
        
        // Wait a bit before showing popup
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Show premium popup after ad
        if (context.mounted) {
          _showPremiumPopup(context);
        }
      } else {
        // If no interstitial available, show popup directly
        if (kDebugMode) {
          print('AppLaunchService: No interstitial ad available, showing popup directly');
        }
        _showPremiumPopup(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppLaunchService: Error showing launch experience: $e');
      }
      // Fallback to showing popup
      if (context.mounted) {
        _showPremiumPopup(context);
      }
    }
  }

  void _showPremiumPopup(BuildContext context) {
    if (kDebugMode) {
      print('AppLaunchService: Showing premium popup');
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PremiumPopup(),
    );
  }

  /// Reset the launch flag (useful for testing)
  void resetLaunchFlag() {
    _hasShownLaunchAd = false;
  }
}