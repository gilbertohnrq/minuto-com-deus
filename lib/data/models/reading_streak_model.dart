import '../../domain/entities/reading_streak.dart';

class ReadingStreakModel extends ReadingStreak {
  const ReadingStreakModel({
    required super.userId,
    required super.currentStreak,
    required super.longestStreak,
    required super.lastReflectionDate,
    required super.reflectionDates,
  });

  factory ReadingStreakModel.fromJson(Map<String, dynamic> json) {
    return ReadingStreakModel(
      userId: json['userId'] as String,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastReflectionDate: DateTime.parse(json['lastReflectionDate'] as String),
      reflectionDates: (json['reflectionDates'] as List<dynamic>)
          .map((date) => DateTime.parse(date as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReflectionDate': lastReflectionDate.toIso8601String(),
      'reflectionDates': reflectionDates
          .map((date) => date.toIso8601String())
          .toList(),
    };
  }

  factory ReadingStreakModel.fromEntity(ReadingStreak streak) {
    return ReadingStreakModel(
      userId: streak.userId,
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      lastReflectionDate: streak.lastReflectionDate,
      reflectionDates: streak.reflectionDates,
    );
  }

  ReadingStreak toEntity() {
    return ReadingStreak(
      userId: userId,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastReflectionDate: lastReflectionDate,
      reflectionDates: reflectionDates,
    );
  }

  factory ReadingStreakModel.initial(String userId) {
    final now = DateTime.now();
    return ReadingStreakModel(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastReflectionDate: now,
      reflectionDates: [],
    );
  }
}