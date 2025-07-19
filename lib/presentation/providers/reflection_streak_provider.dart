import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reading_streak.dart';
import '../../services/reflection_service.dart';
import '../../services/reading_streak_service.dart';
import '../../services/ad_service.dart';
import 'auth_provider.dart';
import 'reflection_provider.dart';
import 'reading_streak_provider.dart';
import 'ad_provider.dart';

/// Combined state for reflection submission and streak updates
class ReflectionStreakState {
  final bool isSubmitting;
  final String? errorMessage;
  final bool showStreakAnimation;
  final int? newStreakCount;
  final bool isMilestone;

  const ReflectionStreakState({
    this.isSubmitting = false,
    this.errorMessage,
    this.showStreakAnimation = false,
    this.newStreakCount,
    this.isMilestone = false,
  });

  ReflectionStreakState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? showStreakAnimation,
    int? newStreakCount,
    bool? isMilestone,
  }) {
    return ReflectionStreakState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      showStreakAnimation: showStreakAnimation ?? this.showStreakAnimation,
      newStreakCount: newStreakCount ?? this.newStreakCount,
      isMilestone: isMilestone ?? this.isMilestone,
    );
  }
}

/// Notifier that handles reflection submission, streak updates, and ad display
class ReflectionStreakNotifier extends StateNotifier<ReflectionStreakState> {
  final ReflectionService _reflectionService;
  final ReadingStreakService _streakService;
  final AdService _adService;
  final Ref _ref;

  ReflectionStreakNotifier(
    this._reflectionService,
    this._streakService,
    this._adService,
    this._ref,
  ) : super(const ReflectionStreakState());

  /// Submit reflection, update streak, show animation, and display ad
  Future<void> submitReflection(String devotionalId, String content) async {
    final authState = _ref.read(authStateProvider);
    
    await authState.when(
      data: (user) async {
        if (user == null) {
          state = state.copyWith(errorMessage: 'Usuário não autenticado');
          return;
        }

        // Validate content
        final validationError = _reflectionService.getValidationError(content);
        if (validationError != null) {
          state = state.copyWith(errorMessage: validationError);
          return;
        }

        state = state.copyWith(isSubmitting: true, errorMessage: null);

        try {
          // 1. Save reflection
          await _reflectionService.saveReflection(devotionalId, user.uid, content);

          // 2. Update streak
          final oldStreak = await _streakService.getCurrentStreak(user.uid);
          final newStreak = await _streakService.recordReflection(user.uid, DateTime.now());

          // 3. Check if streak increased (for animation)
          final streakIncreased = newStreak.currentStreak > oldStreak.currentStreak;
          final isMilestone = _streakService.isStreakMilestone(newStreak.currentStreak);

          // 4. Update state with animation trigger
          state = state.copyWith(
            isSubmitting: false,
            showStreakAnimation: streakIncreased,
            newStreakCount: newStreak.currentStreak,
            isMilestone: isMilestone,
          );

          // 5. Invalidate related providers to refresh UI
          _ref.invalidate(todayReflectionProvider(devotionalId));
          _ref.invalidate(userReflectionsProvider);
          _ref.invalidate(hasReflectedTodayProvider);
          _ref.invalidate(currentReadingStreakProvider);
          _ref.invalidate(streakStatsProvider);

          // 6. Show ad for non-premium users (after a short delay to let animation show)
          await Future.delayed(const Duration(milliseconds: 1500));
          await _showAdIfNeeded(user.uid);

        } catch (error) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: 'Erro ao salvar reflexão: $error',
          );
        }
      },
      loading: () async {
        state = state.copyWith(errorMessage: 'Carregando autenticação...');
      },
      error: (error, _) async {
        state = state.copyWith(errorMessage: 'Erro de autenticação: $error');
      },
    );
  }

  /// Show ad for non-premium users
  Future<void> _showAdIfNeeded(String userId) async {
    try {
      // Check if user is premium (this would need to be implemented based on your user model)
      // For now, we'll assume all users see ads
      final shouldShowAd = true; // Replace with actual premium check
      
      if (shouldShowAd) {
        await _adService.showInterstitialAd();
      }
    } catch (e) {
      // Ignore ad errors - don't let them affect the reflection submission
      print('Ad display error: $e');
    }
  }

  /// Clear the streak animation state
  void clearStreakAnimation() {
    state = state.copyWith(
      showStreakAnimation: false,
      newStreakCount: null,
      isMilestone: false,
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Validate reflection content
  String? validateContent(String content) {
    return _reflectionService.getValidationError(content);
  }
}

/// Provider for the combined reflection and streak notifier
final reflectionStreakNotifierProvider = 
    StateNotifierProvider<ReflectionStreakNotifier, ReflectionStreakState>((ref) {
  final reflectionService = ref.watch(reflectionServiceProvider);
  final streakService = ref.watch(readingStreakServiceProvider);
  final adService = ref.watch(adServiceProvider);
  
  return ReflectionStreakNotifier(
    reflectionService,
    streakService,
    adService,
    ref,
  );
});

/// Convenience provider to check if streak animation should be shown
final shouldShowStreakAnimationProvider = Provider<bool>((ref) {
  final state = ref.watch(reflectionStreakNotifierProvider);
  return state.showStreakAnimation;
});

/// Convenience provider to get the new streak count for animation
final newStreakCountProvider = Provider<int?>((ref) {
  final state = ref.watch(reflectionStreakNotifierProvider);
  return state.newStreakCount;
});

/// Convenience provider to check if the new streak is a milestone
final isStreakMilestoneProvider = Provider<bool>((ref) {
  final state = ref.watch(reflectionStreakNotifierProvider);
  return state.isMilestone;
});