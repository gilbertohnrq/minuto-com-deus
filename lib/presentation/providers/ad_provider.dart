import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/ad_service.dart';
import 'local_user_provider.dart';

/// Provider for AdService
final adServiceProvider = Provider<AdService>((ref) {
  return AdService.instance;
});

/// Provider to check if ads should be shown (non-premium users)
final shouldShowAdsProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentLocalUserProvider);
  // Show ads if user is not premium
  return currentUser?.isActivePremium != true;
});

/// Provider for ad state management
final adNotifierProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  final adService = ref.watch(adServiceProvider);
  return AdNotifier(adService);
});

/// Ad state
class AdState {
  final bool isBannerLoaded;
  final bool isInterstitialLoaded;
  final bool isLoading;
  final String? errorMessage;

  const AdState({
    this.isBannerLoaded = false,
    this.isInterstitialLoaded = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AdState copyWith({
    bool? isBannerLoaded,
    bool? isInterstitialLoaded,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdState(
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      isInterstitialLoaded: isInterstitialLoaded ?? this.isInterstitialLoaded,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Ad state notifier
class AdNotifier extends StateNotifier<AdState> {
  final AdService _adService;

  AdNotifier(this._adService) : super(const AdState());

  /// Load banner ad
  Future<void> loadBannerAd() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _adService.loadBannerAd();
      state = state.copyWith(
        isLoading: false,
        isBannerLoaded: _adService.isBannerAdLoaded,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _adService.loadInterstitialAd();
      state = state.copyWith(
        isLoading: false,
        isInterstitialLoaded: _adService.isInterstitialAdLoaded,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    try {
      await _adService.showInterstitialAd();
      // Update state after showing
      state = state.copyWith(
        isInterstitialLoaded: _adService.isInterstitialAdLoaded,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Dispose ads
  @override
  void dispose() {
    _adService.dispose();
    state = const AdState();
    super.dispose();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
