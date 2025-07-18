import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/local_user_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
