import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reading_streak.dart';
import '../../services/reading_streak_service.dart';
import '../../services/local_user_service.dart';
import '../../services/notification_service.dart';

/// Provider for LocalUserService
final localUserServiceProvider = Provider<LocalUserService>((ref) {
  return LocalUserService.instance;
});

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for ReadingStreakService
final readingStreakServiceProvider = Provider<ReadingStreakService>((ref) {
  final localUserService = ref.watch(localUserServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ReadingStreakService(localUserService, notificationService);
});

/// Provider for current reading streak
final currentReadingStreakProvider = FutureProvider<ReadingStreak>((ref) async {
  final streakService = ref.watch(readingStreakServiceProvider);
  return await streakService.getCurrentStreak();
});

/// Provider for streak statistics
final streakStatsProvider = FutureProvider<StreakStats>((ref) async {
  final streakService = ref.watch(readingStreakServiceProvider);
  return await streakService.getStreakStats();
});

/// Provider to check if user has read today
final hasReadTodayProvider = FutureProvider<bool>((ref) async {
  final streakService = ref.watch(readingStreakServiceProvider);
  return await streakService.hasReadToday();
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
  Future<void> loadCurrentStreak() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final streak = await _streakService.getCurrentStreak();
      final stats = await _streakService.getStreakStats();
      
      state = state.copyWith(
        isLoading: false,
        currentStreak: streak,
        stats: stats,
        hasReadToday: streak.hasReadToday,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar streak: ${e.toString()}',
      );
    }
  }

  /// Mark today's devotional as read
  Future<void> markAsRead([DateTime? date]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final readDate = date ?? DateTime.now();
      final newStreak = await _streakService.markAsRead(readDate);
      final stats = await _streakService.getStreakStats();
      
      state = state.copyWith(
        isLoading: false,
        currentStreak: newStreak,
        stats: stats,
        hasReadToday: newStreak.hasReadToday,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao marcar como lido: ${e.toString()}',
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
  Future<void> resetStreak() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _streakService.resetStreak();
      await loadCurrentStreak();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao resetar streak: ${e.toString()}',
      );
    }
  }

  /// Refresh streak data
  Future<void> refreshStreak() async {
    await loadCurrentStreak();
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

/// Provider for streak milestone notification
final streakMilestoneProvider = Provider<StreakMilestone?>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  return streakState.currentStreak?.getStreakMilestone();
});

/// Provider for streak status message
final streakStatusMessageProvider = Provider<String>((ref) {
  final streakState = ref.watch(readingStreakNotifierProvider);
  final hasReadToday = streakState.hasReadToday;
  final currentStreak = streakState.currentStreak?.currentStreak ?? 0;
  final isActive = streakState.currentStreak?.isStreakActive ?? false;

  if (hasReadToday) {
    if (currentStreak == 1) {
      return 'Parabéns! Você iniciou sua jornada 🎉';
    } else {
      return 'Devocional de hoje concluído! 🙏';
    }
  } else if (isActive && currentStreak > 0) {
    return 'Continue sua sequência de $currentStreak dias 📖';
  } else {
    return 'Que tal começar sua jornada hoje? ✨';
  }
});

/// Provider for streak encouragement message
final streakEncouragementProvider = Provider<String>((ref) {
  final currentStreak = ref.watch(currentStreakNumberProvider);
  final hasReadToday = ref.watch(readingStreakNotifierProvider).hasReadToday;
  
  if (hasReadToday) {
    return 'Você está no controle! 💪';
  }
  
  if (currentStreak == 0) {
    return 'Todo grande começo inicia com um primeiro passo 🌱';
  } else if (currentStreak < 7) {
    return 'Você está construindo um hábito fantástico! 🌟';
  } else if (currentStreak < 30) {
    return 'Sua disciplina é inspiradora! 🔥';
  } else {
    return 'Você é um exemplo de dedicação! 👑';
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