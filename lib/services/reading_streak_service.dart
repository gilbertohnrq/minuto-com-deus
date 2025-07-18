import '../domain/entities/reading_streak.dart';
import 'local_user_service.dart';
import 'notification_service.dart';

/// Service for managing reading streaks and daily reading tracking
class ReadingStreakService {
  final LocalUserService _localUserService;
  final NotificationService _notificationService;
  
  ReadingStreakService(this._localUserService, this._notificationService);
  
  /// Mark today's devotional as read and update streak
  Future<ReadingStreak> markAsRead(DateTime date) async {
    try {
      // Get current user
      final currentUser = await _localUserService.getUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }
      
      // Update streak
      final newStreak = currentUser.readingStreak.markAsRead(date);
      
      // Update user with new streak
      final updatedUser = currentUser.copyWith(readingStreak: newStreak);
      await _localUserService.updateUser(updatedUser);
      
      // Cancel today's reading reminder notifications
      await _cancelTodayReadingNotifications();
      
      // Check for milestone notification
      final milestone = newStreak.getStreakMilestone();
      if (milestone != null) {
        await _scheduleMilestoneNotification(milestone);
      }
      
      return newStreak;
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }
  
  /// Get current reading streak
  Future<ReadingStreak> getCurrentStreak() async {
    try {
      final user = await _localUserService.getUser();
      return user?.readingStreak ?? ReadingStreak.empty();
    } catch (e) {
      throw Exception('Failed to get current streak: $e');
    }
  }
  
  /// Check if user has read today's devotional
  Future<bool> hasReadToday() async {
    try {
      final streak = await getCurrentStreak();
      return streak.hasReadToday;
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
      
      // Check if user has already read today
      if (await hasReadToday()) {
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
  Future<void> _scheduleMilestoneNotification(StreakMilestone milestone) async {
    try {
      await _notificationService.scheduleImmediate(
        notificationId: 200, // Milestone notification ID
        title: 'Parabéns! 🎉',
        body: milestone.message,
      );
    } catch (e) {
      // Ignore milestone notification errors
    }
  }
  
  /// Get streak statistics
  Future<StreakStats> getStreakStats() async {
    try {
      final streak = await getCurrentStreak();
      final user = await _localUserService.getUser();
      
      if (user == null) {
        return StreakStats.empty();
      }
      
      final daysSinceCreation = DateTime.now().difference(user.createdAt).inDays + 1;
      final readingRate = daysSinceCreation > 0 
          ? (streak.totalDaysRead / daysSinceCreation * 100).round()
          : 0;
      
      return StreakStats(
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        totalDaysRead: streak.totalDaysRead,
        readingRate: readingRate,
        hasReadToday: streak.hasReadToday,
        isStreakActive: streak.isStreakActive,
        daysSinceLastRead: streak.daysSinceLastRead,
      );
    } catch (e) {
      return StreakStats.empty();
    }
  }
  
  /// Reset streak (for testing or user request)
  Future<void> resetStreak() async {
    try {
      final user = await _localUserService.getUser();
      if (user == null) return;
      
      final resetStreak = ReadingStreak.empty();
      final updatedUser = user.copyWith(readingStreak: resetStreak);
      await _localUserService.updateUser(updatedUser);
    } catch (e) {
      throw Exception('Failed to reset streak: $e');
    }
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