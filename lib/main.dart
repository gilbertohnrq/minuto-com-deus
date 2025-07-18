import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'services/ad_service.dart';
import 'services/local_user_service.dart';
import 'services/notification_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional for CI builds)
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ No .env file found, using system environment or defaults');
  }

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize locale data for internationalization
  await initializeDateFormatting('pt_BR', null);
  await initializeDateFormatting('en_US', null);

  // Try to initialize Firebase (skip if config missing in CI)
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization skipped: $e');
    // Continue without Firebase for CI builds
  }

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize local user service for freemium model
  final localUserService = LocalUserService.instance;
  await localUserService.initialize();

  // Initialize subscription service
  final subscriptionService = SubscriptionService.instance;
  await subscriptionService.initialize();

  // Initialize ad service
  final adService = AdService.instance;
  await adService.initialize();

  // Load interstitial ad for app launch
  try {
    await adService.loadInterstitialAd();
    print('✅ Interstitial ad loaded for app launch');
  } catch (e) {
    print('⚠️ Failed to load interstitial ad: $e');
  }

  // Note: Skipping AuthService initialization for freemium model
  // Firebase Auth will be used only when real authentication is needed

  runApp(
    const ProviderScope(
      child: DevotionalApp(),
    ),
  );
}

class DevotionalApp extends StatelessWidget {
  const DevotionalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
