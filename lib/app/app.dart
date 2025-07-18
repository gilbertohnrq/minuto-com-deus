import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/premium/premium_screen.dart';
import '../presentation/providers/local_user_provider.dart';
import '../presentation/providers/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);
    
    return MaterialApp(
      title: 'Devocional Diário',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routes: {
        '/': (context) => Consumer(
          builder: (context, ref, child) {
            final user = ref.watch(currentLocalUserProvider);
            
            // Show loading while user data is being loaded
            if (user == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Always go to home screen in freemium model
            return const HomeScreen();
          },
        ),
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/premium': (context) => const PremiumScreen(),
      },
      initialRoute: '/',
    );
  }
}