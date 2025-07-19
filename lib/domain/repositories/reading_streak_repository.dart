import '../entities/reading_streak.dart';

abstract class ReadingStreakRepository {
  /// Get the current reading streak for a user
  Future<ReadingStreak> getUserStreak(String userId);

  /// Update the reading streak
  Future<void> updateStreak(ReadingStreak streak);

  /// Increment streak when user adds a reflection
  Future<ReadingStreak> incrementStreak(String userId, DateTime reflectionDate);

  /// Reset streak to 0
  Future<void> resetStreak(String userId);

  /// Check if streak should be reset based on missed days
  Future<bool> shouldResetStreak(String userId);

  /// Get streak milestones (7, 30, 100 days)
  List<int> getStreakMilestones();

  /// Check if current streak is a milestone
  bool isStreakMilestone(int streak);
}