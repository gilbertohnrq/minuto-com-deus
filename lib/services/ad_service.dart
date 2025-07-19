import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../utils/env_helper.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  
  AdService._();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;

  // Ad unit IDs from environment variables (fallback to test IDs for development)
  static String get _bannerAdUnitId => Platform.isAndroid
      ? EnvHelper.getEnvOrDefault('ADMOB_BANNER_ANDROID', 'ca-app-pub-3940256099942544/6300978111')
      : EnvHelper.getEnvOrDefault('ADMOB_BANNER_IOS', 'ca-app-pub-3940256099942544/2934735716');

  static String get _interstitialAdUnitId => Platform.isAndroid
      ? EnvHelper.getEnvOrDefault('ADMOB_INTERSTITIAL_ANDROID', 'ca-app-pub-3940256099942544/1033173712')
      : EnvHelper.getEnvOrDefault('ADMOB_INTERSTITIAL_IOS', 'ca-app-pub-3940256099942544/4411468910');

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        print('AdService: Mobile Ads SDK initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdService: Failed to initialize Mobile Ads SDK: $e');
      }
    }
  }

  /// Load banner ad
  Future<void> loadBannerAd() async {
    try {
      final completer = Completer<void>();
      
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            if (kDebugMode) {
              print('AdService: Banner ad loaded successfully');
            }
            completer.complete();
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            if (kDebugMode) {
              print('AdService: Banner ad failed to load: $error');
            }
            completer.completeError(error);
          },
          onAdOpened: (ad) {
            if (kDebugMode) {
              print('AdService: Banner ad opened');
            }
          },
          onAdClosed: (ad) {
            if (kDebugMode) {
              print('AdService: Banner ad closed');
            }
          },
        ),
      );

      await _bannerAd!.load();
      await completer.future;
    } catch (e) {
      _isBannerAdLoaded = false;
      if (kDebugMode) {
        print('AdService: Error loading banner ad: $e');
      }
      rethrow;
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    try {
      final completer = Completer<void>();
      
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            if (kDebugMode) {
              print('AdService: Interstitial ad loaded successfully');
            }

            // Set full screen content callback
            _interstitialAd!.setImmersiveMode(true);
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                if (kDebugMode) {
                  print('AdService: Interstitial ad showed full screen content');
                }
              },
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                if (kDebugMode) {
                  print('AdService: Interstitial ad dismissed');
                }
                // Preload next interstitial ad
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoaded = false;
                if (kDebugMode) {
                  print('AdService: Interstitial ad failed to show: $error');
                }
              },
            );
            completer.complete();
          },
          onAdFailedToLoad: (error) {
            _isInterstitialAdLoaded = false;
            if (kDebugMode) {
              print('AdService: Interstitial ad failed to load: $error');
            }
            completer.completeError(error);
          },
        ),
      );
      
      await completer.future;
    } catch (e) {
      _isInterstitialAdLoaded = false;
      if (kDebugMode) {
        print('AdService: Error loading interstitial ad: $e');
      }
      rethrow;
    }
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      try {
        await _interstitialAd!.show();
      } catch (e) {
        if (kDebugMode) {
          print('AdService: Error showing interstitial ad: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('AdService: Interstitial ad not ready to show');
      }
    }
  }

  /// Dispose banner ad
  void disposeBannerAd() {
    try {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
      if (kDebugMode) {
        print('AdService: Banner ad disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdService: Error disposing banner ad: $e');
      }
    }
  }

  /// Dispose interstitial ad
  void disposeInterstitialAd() {
    try {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
      if (kDebugMode) {
        print('AdService: Interstitial ad disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AdService: Error disposing interstitial ad: $e');
      }
    }
  }

  /// Dispose all ads
  void dispose() {
    disposeBannerAd();
    disposeInterstitialAd();
  }

  /// Getters
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  BannerAd? get bannerAd => _bannerAd;
  InterstitialAd? get interstitialAd => _interstitialAd;
}