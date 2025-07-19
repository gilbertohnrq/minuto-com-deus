import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/reading_streak_local_datasource.dart';
import '../../data/repositories/reading_streak_repository_impl.dart';
import '../../domain/entities/reading_streak.dart';
import '../../domain/repositories/reading_streak_repository.dart';
import '../../services/reading_streak_service.dart';
import '../../services/local_user_service.dart';
import '../../services/notification_service.dart';
import 'auth_provider.dart';

/// Provider for LocalUserService
final localUserServiceProvider = Provider<LocalUserService>((ref) {
  return LocalUserService.instance;
});

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for ReadingStreakLocalDataSource
final readingStreakLocalDataSourceProvider = Provider<ReadingStreakLocalDataSource>((ref) {
  return ReadingStreakLocalDataSourceImpl();
});

/// Provider for ReadingStreakRepository
final readingStreakRepositoryProvider = Provider<ReadingStreakRepository>((ref) {
  final localDataSource = ref.watch(readingStreakLocalDataSourceProvider);
  return ReadingStreakRepositoryImpl(localDataSource: localDataSource);
});

/// Provider for ReadingStreakService
final readingStreakServiceProvider = Provider<ReadingStreakService>((ref) {
  final streakRepository = ref.watch(readingStreakRepositoryProvider);
  final localUserService = ref.watch(localUserServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ReadingStreakService(streakRepository, localUserService, notificationService);
});

/// Provider for current reading streak
final currentReadingStreakProvider = FutureProvider<ReadingStreak>((ref) async {
  final streakService = ref.watch(readingStreakServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) {
        return ReadingStreak(
          userId: '',
          currentStreak: 0,
          longestStreak: 0,
          lastReflectionDate: DateTime.now(),
          reflectionDates: [],
        );
      }
      return await streakService.getCurrentStreak(user.uid);
    },
    loading: () => ReadingStreak(
      userId: '',
      currentStreak: 0,
      longestStreak: 0,
      lastReflectionDate: DateTime.now(),
      reflectionDates: [],
    ),
    error: (_, __) => ReadingStreak(
      userId: '',
      currentStreak: 0,
      longestStreak: 0,
      lastReflectionDate: DateTime.now(),
      reflectionDates: [],
    ),
  );
});

/// Provider for streak statistics
final streakStatsProvider = FutureProvider<StreakStats>((ref) async {
  final streakService = ref.watch(readingStreakServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return StreakStats.empty();
      return await streakService.getStreakStats(user.uid);
    },
    loading: () => StreakStats.empty(),
    error: (_, __) => StreakStats.empty(),
  );
});

/// Provider to check if user has reflected today
final hasReflectedTodayProvider = FutureProvider<bool>((ref) async {
  final streakService = ref.watch(readingStreakServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return false;
      return await streakService.hasReflectedToday(user.uid);
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// State class for reading streak operations
class ReadingStreakState {
  final bool isLoading;
  final String? errorMessage;
  final ReadingStreak? currentStreak;
  final StreakStats? stats;
  final bool hasReadToday;

  const ReadingStreakState({
    this.isLoading = false,
    this.errorMessage,
    this.currentStreak,
    this.stats,
    this.hasReadToday = false,
  });

  ReadingStreakState copyWith({
    bool? isLoading,
    String? errorMessage,
    ReadingStreak? currentStreak,
    StreakStats? stats,
    bool? hasReadToday,
  }) {
    return ReadingStreakState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentStreak: currentStreak ?? this.currentStreak,
      stats: stats ?? this.stats,
      hasReadToday: hasReadToday ?? this.hasReadToday,
    );
  }
}

/// Reading streak state notifier for complex operations
class ReadingStreakNotifier extends StateNotifier<ReadingStreakState> {
  final ReadingStreakService _streakService;

  ReadingStreakNotifier(this._streakService) : super(const ReadingStreakState());

  /// Load current streak and stats
  Future<void> loadCurrentStreak(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final streak = await _streakService.getCurrentStreak(userId);
      final stats = await _streakService.getStreakStats(userId);
      
      state = state.copyWith(
        isLoading: false,
        currentStreak: streak,
        stats: stats,
        hasReadToday: streak.hasReflectedToday,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar streak: ${e.toString()}',
      );
    }
  }

  /// Record reflection and update streak
  Future<void> recordReflection(String userId, [DateTime? date]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reflectionDate = date ?? DateTime.now();
      final newStreak = await _streakService.recordReflection(userId, reflectionDate);
      final stats = await _streakService.getStreakStats(userId);
      
      state = state.copyWith(
        isLoading: false,
        currentStreak: newStreak,
        stats: stats,
        hasReadToday: newStreak.hasReflectedToday,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar reflexão: ${e.toString()}',
      );
    }
  }

  /// Schedule reading reminders
  Future<void> scheduleReadingReminders({
    List<int> reminderHours = const [9, 14, 19, 21],
  }) async {
    try {
      await _streakService.scheduleReadingReminders(reminderHours: reminderHours);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao agendar lembretes: ${e.toString()}',
      );
    }
  }

  /// Reset streak (for testing)
  Future<void> resetStreak(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _streakService.resetStreak(userId);
      await loadCurrentStreak(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao resetar streak: ${e.toString()}',
      );
    }
  }

  /// Refresh streak data
  Future<void> refreshStreak(String userId) async {
    await loadCurrentStreak(userId);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for reading streak state notifier
final readingStreakNotifierProvider =
    StateNotifierProvider<ReadingStreakNotifier, ReadingStreakState>((ref) {
  final streakService = ref.watch(readingStreakServiceProvider);
  return ReadingStreakNotifier(streakService);
});

/// Convenience provider to get current streak number
final currentStreakNumberProvider = Provider<int>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  return streakState.currentStreak?.currentStreak ?? 0;
});

/// Convenience provider to get longest streak number
final longestStreakNumberProvider = Provider<int>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  return streakState.currentStreak?.longestStreak ?? 0;
});

/// Convenience provider to check if streak is active
final isStreakActiveProvider = Provider<bool>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  return streakState.currentStreak?.isStreakActive ?? false;
});

/// Convenience provider to get total days read
final totalDaysReadProvider = Provider<int>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  return streakState.currentStreak?.totalDaysRead ?? 0;
});

/// Provider for streak milestone check
final streakMilestoneProvider = Provider<bool>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  final streakService = ref.watch(readingStreakServiceProvider);
  final currentStreak = streakState.currentStreak?.currentStreak ?? 0;
  return streakService.isStreakMilestone(currentStreak);
});

/// Provider for streak status message
final streakStatusMessageProvider = Provider<String>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  final hasReflectedToday = streakState.hasReadToday;
  final currentStreak = streakState.currentStreak?.currentStreak ?? 0;
  final isActive = streakState.currentStreak?.isStreakActive ?? false;

  if (hasReflectedToday) {
    if (currentStreak == 1) {
      return 'Parabéns! Você iniciou sua jornada de reflexões 🎉';
    } else {
      return 'Reflexão de hoje concluída! 🙏';
    }
  } else if (isActive && currentStreak > 0) {
    return 'Continue sua sequência de $currentStreak dias de reflexões 📖';
  } else {
    return 'Que tal começar sua jornada de reflexões hoje? ✨';
  }
});

/// Provider for streak encouragement message
final streakEncouragementProvider = Provider<String>((ref) {
  final currentStreak = ref.watch(currentStreakNumberProvider);
  final hasReflectedToday = ref.watch(readingStreakNotifierProvider).hasReadToday;
  
  if (hasReflectedToday) {
    return 'Você está no controle! 💪';
  }
  
  if (currentStreak == 0) {
    return 'Todo grande começo inicia com uma primeira reflexão 🌱';
  } else if (currentStreak < 7) {
    return 'Você está construindo um hábito fantástico de reflexão! 🌟';
  } else if (currentStreak < 30) {
    return 'Sua disciplina em refletir é inspiradora! 🔥';
  } else {
    return 'Você é um exemplo de dedicação às reflexões! 👑';
  }
});

/// Provider for notification reminder times
final reminderTimesProvider = StateProvider<List<int>>((ref) {
  return [9, 14, 19, 21]; // 9am, 2pm, 7pm, 9pm
});

/// Provider to initialize reading reminders on app start
final initializeReadingRemindersProvider = FutureProvider<void>((ref) async {
  final streakNotifier = ref.watch(readingStreakNotifierProvider.notifier);
  final reminderTimes = ref.watch(reminderTimesProvider);
  
  // Schedule reminders with current times
  await streakNotifier.scheduleReadingReminders(reminderHours: reminderTimes);
});