import '../domain/entities/reading_streak.dart';
import '../domain/repositories/reading_streak_repository.dart';
import 'local_user_service.dart';
import 'notification_service.dart';

/// Service for managing reading streaks and daily reading tracking
class ReadingStreakService {
  final ReadingStreakRepository _streakRepository;
  final LocalUserService _localUserService;
  final NotificationService _notificationService;
  
  ReadingStreakService(
    this._streakRepository,
    this._localUserService, 
    this._notificationService,
  );
  
  /// Record a reflection and update streak
  Future<ReadingStreak> recordReflection(String userId, DateTime reflectionDate) async {
    try {
      // Increment streak based on reflection
      final newStreak = await _streakRepository.incrementStreak(userId, reflectionDate);
      
      // Cancel today's reading reminder notifications
      await _cancelTodayReadingNotifications();
      
      // Check for milestone notification
      if (_streakRepository.isStreakMilestone(newStreak.currentStreak)) {
        await _scheduleMilestoneNotification(newStreak.currentStreak);
      }
      
      return newStreak;
    } catch (e) {
      throw Exception('Failed to record reflection: $e');
    }
  }
  
  /// Get current reading streak
  Future<ReadingStreak> getCurrentStreak(String userId) async {
    try {
      return await _streakRepository.getUserStreak(userId);
    } catch (e) {
      throw Exception('Failed to get current streak: $e');
    }
  }
  
  /// Check if user has reflected today
  Future<bool> hasReflectedToday(String userId) async {
    try {
      final streak = await getCurrentStreak(userId);
      return streak.hasReflectedToday;
    } catch (e) {
      return false;
    }
  }
  
  /// Schedule multiple reading reminder notifications throughout the day
  Future<void> scheduleReadingReminders({
    List<int> reminderHours = const [9, 14, 19, 21], // 9am, 2pm, 7pm, 9pm
  }) async {
    try {
      // Cancel existing reading reminders
      await _cancelReadingReminders();
      
      // Get current user
      final currentUser = await _localUserService.getUser();
      if (currentUser == null) return;
      
      // Check if user has already reflected today
      if (await hasReflectedToday(currentUser.id)) {
        return; // No need to schedule reminders
      }
      
      // Get current user for notification settings
      final user = await _localUserService.getUser();
      if (user == null || !user.notificationSettings.enabled) {
        return; // User has notifications disabled
      }
      
      // Schedule reminders for each hour
      for (int i = 0; i < reminderHours.length; i++) {
        final hour = reminderHours[i];
        final notificationId = 100 + i; // Start from ID 100 for reading reminders
        
        await _notificationService.scheduleReadingReminder(
          notificationId: notificationId,
          hour: hour,
          minute: 0,
          title: _getReminderTitle(hour),
          body: _getReminderBody(hour),
        );
      }
    } catch (e) {
      throw Exception('Failed to schedule reading reminders: $e');
    }
  }
  
  /// Cancel all reading reminder notifications
  Future<void> _cancelReadingReminders() async {
    try {
      // Cancel reading reminder notifications (IDs 100-110)
      for (int i = 100; i < 110; i++) {
        await _notificationService.cancelNotification(i);
      }
    } catch (e) {
      // Ignore cancellation errors
    }
  }
  
  /// Cancel today's reading notifications (called when user reads devotional)
  Future<void> _cancelTodayReadingNotifications() async {
    try {
      await _cancelReadingReminders();
    } catch (e) {
      // Ignore cancellation errors
    }
  }
  
  /// Schedule milestone achievement notification
  Future<void> _scheduleMilestoneNotification(int streakCount) async {
    try {
      String message;
      switch (streakCount) {
        case 7:
          message = 'Você completou 7 dias de reflexões! Continue assim! 🔥';
          break;
        case 30:
          message = 'Incrível! 30 dias de reflexões diárias! Você é inspirador! ⭐';
          break;
        case 100:
          message = 'Extraordinário! 100 dias de reflexões! Sua dedicação é admirável! 🏆';
          break;
        default:
          message = 'Parabéns por manter sua sequência de reflexões! 🎉';
      }
      
      await _notificationService.scheduleImmediate(
        notificationId: 200, // Milestone notification ID
        title: 'Parabéns! 🎉',
        body: message,
      );
    } catch (e) {
      // Ignore milestone notification errors
    }
  }
  
  /// Get streak statistics
  Future<StreakStats> getStreakStats(String userId) async {
    try {
      final streak = await getCurrentStreak(userId);
      final user = await _localUserService.getUser();
      
      if (user == null) {
        return StreakStats.empty();
      }
      
      final daysSinceCreation = DateTime.now().difference(user.createdAt).inDays + 1;
      final totalDaysRead = streak.reflectionDates.length;
      final readingRate = daysSinceCreation > 0 
          ? (totalDaysRead / daysSinceCreation * 100).round()
          : 0;
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastReflectionDay = DateTime(
        streak.lastReflectionDate.year,
        streak.lastReflectionDate.month,
        streak.lastReflectionDate.day,
      );
      final daysSinceLastRead = today.difference(lastReflectionDay).inDays;
      
      return StreakStats(
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        totalDaysRead: totalDaysRead,
        readingRate: readingRate,
        hasReadToday: streak.hasReflectedToday,
        isStreakActive: streak.isStreakActive,
        daysSinceLastRead: daysSinceLastRead,
      );
    } catch (e) {
      return StreakStats.empty();
    }
  }
  
  /// Reset streak (for testing or user request)
  Future<void> resetStreak(String userId) async {
    try {
      await _streakRepository.resetStreak(userId);
    } catch (e) {
      throw Exception('Failed to reset streak: $e');
    }
  }
  
  /// Check if streak milestone was reached
  bool isStreakMilestone(int streak) {
    return _streakRepository.isStreakMilestone(streak);
  }
  
  /// Get available streak milestones
  List<int> getStreakMilestones() {
    return _streakRepository.getStreakMilestones();
  }
  
  // Helper methods for notification content
  String _getReminderTitle(int hour) {
    if (hour < 12) {
      return 'Bom dia! ☀️';
    } else if (hour < 18) {
      return 'Boa tarde! 🌤️';
    } else {
      return 'Boa noite! 🌙';
    }
  }
  
  String _getReminderBody(int hour) {
    final messages = [
      'Que tal começar o dia com uma reflexão? 🙏',
      'Hora de nutrir sua alma com a palavra de Deus 📖',
      'Seu devocional diário está esperando por você ✨',
      'Alguns minutos com Deus podem transformar seu dia 💝',
      'Sua dose diária de inspiração está aqui 🌟',
      'Que tal dedicar alguns minutos para sua fé? 🤲',
    ];
    
    // Different message based on time of day
    if (hour < 12) {
      return messages[0]; // Morning
    } else if (hour < 15) {
      return messages[1]; // Early afternoon
    } else if (hour < 18) {
      return messages[2]; // Late afternoon
    } else {
      return messages[3]; // Evening
    }
  }
}

/// Extension to add reading reminder scheduling to NotificationService
extension ReadingReminderNotifications on NotificationService {
  Future<void> scheduleReadingReminder({
    required int notificationId,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Schedule recurring daily notification at specified time
    await scheduleDailyNotification(
      notificationId: notificationId,
      hour: hour,
      minute: minute,
      title: title,
      body: body,
    );
  }
  
  Future<void> scheduleImmediate({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    // Schedule immediate notification
    await showNotification(
      notificationId: notificationId,
      title: title,
      body: body,
    );
  }
}

/// Streak statistics model
class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final int totalDaysRead;
  final int readingRate; // Percentage
  final bool hasReadToday;
  final bool isStreakActive;
  final int daysSinceLastRead;
  
  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDaysRead,
    required this.readingRate,
    required this.hasReadToday,
    required this.isStreakActive,
    required this.daysSinceLastRead,
  });
  
  factory StreakStats.empty() {
    return const StreakStats(
      currentStreak: 0,
      longestStreak: 0,
      totalDaysRead: 0,
      readingRate: 0,
      hasReadToday: false,
      isStreakActive: false,
      daysSinceLastRead: 0,
    );
  }
  
  @override
  String toString() {
    return 'StreakStats(current: $currentStreak, longest: $longestStreak, total: $totalDaysRead, rate: $readingRate%)';
  }
}