import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reading_streak_model.dart';

abstract class ReadingStreakLocalDataSource {
  Future<ReadingStreakModel> getUserStreak(String userId);
  Future<void> updateStreak(ReadingStreakModel streak);
  Future<ReadingStreakModel> incrementStreak(String userId, DateTime reflectionDate);
  Future<void> resetStreak(String userId);
  Future<bool> shouldResetStreak(String userId);
}

class ReadingStreakLocalDataSourceImpl implements ReadingStreakLocalDataSource {
  static const String _streakPrefix = 'reading_streak_';
  static const List<int> _milestones = [7, 30, 100];

  @override
  Future<ReadingStreakModel> getUserStreak(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final streakKey = '$_streakPrefix$userId';
    final streakJson = prefs.getString(streakKey);

    if (streakJson != null) {
      return ReadingStreakModel.fromJson(jsonDecode(streakJson));
    }

    // Return initial streak if none exists
    return ReadingStreakModel.initial(userId);
  }

  @override
  Future<void> updateStreak(ReadingStreakModel streak) async {
    final prefs = await SharedPreferences.getInstance();
    final streakKey = '$_streakPrefix${streak.userId}';
    await prefs.setString(streakKey, jsonEncode(streak.toJson()));
  }

  @override
  Future<ReadingStreakModel> incrementStreak(String userId, DateTime reflectionDate) async {
    final currentStreak = await getUserStreak(userId);
    final today = DateTime(reflectionDate.year, reflectionDate.month, reflectionDate.day);
    
    // Check if already reflected today
    final lastReflectionDay = DateTime(
      currentStreak.lastReflectionDate.year,
      currentStreak.lastReflectionDate.month,
      currentStreak.lastReflectionDate.day,
    );

    if (lastReflectionDay.isAtSameMomentAs(today)) {
      // Already reflected today, don't increment
      return currentStreak;
    }

    // Check if streak should continue or reset
    final yesterday = today.subtract(const Duration(days: 1));
    final shouldContinueStreak = lastReflectionDay.isAtSameMomentAs(yesterday) ||
        currentStreak.currentStreak == 0;

    int newCurrentStreak;
    if (shouldContinueStreak) {
      newCurrentStreak = currentStreak.currentStreak + 1;
    } else {
      // Reset streak if more than 1 day gap
      newCurrentStreak = 1;
    }

    final newLongestStreak = newCurrentStreak > currentStreak.longestStreak
        ? newCurrentStreak
        : currentStreak.longestStreak;

    final updatedReflectionDates = List<DateTime>.from(currentStreak.reflectionDates);
    updatedReflectionDates.add(today);

    // Keep only last 365 days of reflection dates for performance
    final oneYearAgo = today.subtract(const Duration(days: 365));
    updatedReflectionDates.removeWhere((date) => date.isBefore(oneYearAgo));

    final newStreak = ReadingStreakModel(
      userId: userId,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastReflectionDate: reflectionDate,
      reflectionDates: updatedReflectionDates,
    );

    await updateStreak(newStreak);
    return newStreak;
  }

  @override
  Future<void> resetStreak(String userId) async {
    final currentStreak = await getUserStreak(userId);
    final resetStreak = ReadingStreakModel(
      userId: userId,
      currentStreak: 0,
      longestStreak: currentStreak.longestStreak,
      lastReflectionDate: currentStreak.lastReflectionDate,
      reflectionDates: currentStreak.reflectionDates,
    );

    await updateStreak(resetStreak);
  }

  @override
  Future<bool> shouldResetStreak(String userId) async {
    final streak = await getUserStreak(userId);
    
    if (streak.currentStreak == 0) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReflectionDay = DateTime(
      streak.lastReflectionDate.year,
      streak.lastReflectionDate.month,
      streak.lastReflectionDate.day,
    );

    // Reset if more than 1 day has passed without reflection
    final daysSinceLastReflection = today.difference(lastReflectionDay).inDays;
    return daysSinceLastReflection > 1;
  }

  List<int> getStreakMilestones() => _milestones;

  bool isStreakMilestone(int streak) => _milestones.contains(streak);
}