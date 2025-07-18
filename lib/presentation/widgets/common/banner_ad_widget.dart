import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../providers/ad_provider.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    // Load banner ad when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShowAds = ref.read(shouldShowAdsProvider);
      if (shouldShowAds) {
        ref.read(adNotifierProvider.notifier).loadBannerAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowAds = ref.watch(shouldShowAdsProvider);
    final adState = ref.watch(adNotifierProvider);
    final adService = ref.watch(adServiceProvider);

    // Don't show ads for premium users
    if (!shouldShowAds) {
      return const SizedBox.shrink();
    }

    // Don't show if banner ad is not loaded
    if (!adState.isBannerLoaded || adService.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: adService.bannerAd!.size.width.toDouble(),
      height: adService.bannerAd!.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: adService.bannerAd!),
    );
  }

  @override
  void dispose() {
    // Don't dispose the ad service here as it's a singleton
    // The ad service will handle its own lifecycle
    super.dispose();
  }
}