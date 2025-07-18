import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../services/app_launch_service.dart';
import '../../providers/local_user_provider.dart';
import '../../providers/devotional_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/reading_streak_provider.dart';
import '../../widgets/common/banner_ad_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/main_navigation.dart';
import '../../widgets/devotional/devotional_card.dart';
import '../../widgets/streak/streak_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    // Show launch experience (interstitial ad + premium popup)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShowAds = ref.read(shouldShowAdsProvider);
      if (shouldShowAds) {
        AppLaunchService.instance.showLaunchExperience(context);
      }
      
      // Initialize streak system
      ref.read(readingStreakNotifierProvider.notifier).loadCurrentStreak();
      ref.read(initializeReadingRemindersProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayDevotional = ref.watch(todayDevotionalProvider);
    final currentUser = ref.watch(currentLocalUserProvider);
    final shouldShowAds = ref.watch(shouldShowAdsProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return MainNavigation(
      currentRoute: '/home',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Devocional Diário'),
          backgroundColor: theme.colorScheme.inversePrimary,
          elevation: 0,
          actions: [
            // Theme toggle button
            IconButton(
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              tooltip: 'Alterar tema',
            ),
            // Premium button for non-premium users
            if (shouldShowAds) ...[
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/premium');
                },
                icon: Icon(
                  Icons.workspace_premium,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Premium',
              ),
            ],
            IconButton(
              onPressed: () {
                // Refresh today's devotional
                ref.invalidate(todayDevotionalProvider);
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Atualizar',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Configurações',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayDevotionalProvider);
            // Wait a bit for the provider to refresh
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Welcome section
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.inversePrimary,
                        theme.colorScheme.surface,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.name != null
                              ? 'Olá, ${currentUser!.name}!'
                              : 'Bem-vindo!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontSize: isTablet ? 28 : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hoje é ${app_date_utils.DateUtils.formatDateDisplay(DateTime.now())}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: isTablet ? 18 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Streak card
              SliverToBoxAdapter(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : double.infinity,
                  ),
                  margin: isTablet
                      ? const EdgeInsets.symmetric(horizontal: 40)
                      : EdgeInsets.zero,
                  child: StreakCard(
                    isCompact: false,
                    onTap: () {
                      // TODO: Navigate to streak details page
                    },
                  ),
                ),
              ),

              // Devotional content
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : double.infinity,
                  ),
                  margin: isTablet
                      ? const EdgeInsets.symmetric(horizontal: 40)
                      : EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: todayDevotional.when(
                          data: (devotional) {
                            if (devotional != null) {
                              // Mark as read when devotional is displayed
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ref.read(readingStreakNotifierProvider.notifier).markAsRead();
                              });
                              
                              return DevotionalCard(
                                devotional: devotional,
                                onRefresh: () {
                                  ref.invalidate(todayDevotionalProvider);
                                  ref.read(readingStreakNotifierProvider.notifier).refreshStreak();
                                },
                              );
                            } else {
                              return EmptyStateWidget(
                                message:
                                    'Em breve teremos um devocional para este dia',
                                subtitle:
                                    'Volte em breve para ver o devocional de hoje',
                                icon: Icons.calendar_today,
                                onAction: () {
                                  ref.invalidate(todayDevotionalProvider);
                                },
                                actionLabel: 'Verificar novamente',
                              );
                            }
                          },
                          loading: () => const LoadingWidget(
                            message: 'Carregando devocional de hoje...',
                          ),
                          error: (error, stackTrace) {
                            return AppErrorWidget(
                              message: error
                                      .toString()
                                      .contains('DevotionalNotFoundException')
                                  ? 'Em breve teremos um devocional para este dia'
                                  : 'Erro ao carregar o devocional de hoje',
                              onRetry: () {
                                ref.invalidate(todayDevotionalProvider);
                              },
                              icon: error
                                      .toString()
                                      .contains('DevotionalNotFoundException')
                                  ? Icons.calendar_today
                                  : Icons.error_outline,
                            );
                          },
                        ),
                      ),

                      // Banner ad for non-premium users
                      const BannerAdWidget(),

                      // Footer with app info
                      Container(
                        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                        child: Text(
                          'Devocional Diário - Sua dose diária de inspiração',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontSize: isTablet ? 14 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
