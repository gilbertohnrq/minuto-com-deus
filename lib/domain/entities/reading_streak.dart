class ReadingStreak {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastReflectionDate;
  final List<DateTime> reflectionDates;

  const ReadingStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastReflectionDate,
    required this.reflectionDates,
  });

  bool get isStreakActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastDate = DateTime(
      lastReflectionDate.year,
      lastReflectionDate.month,
      lastReflectionDate.day,
    );

    return lastDate.isAtSameMomentAs(today) ||
        lastDate.isAtSameMomentAs(yesterday);
  }

  bool get hasReflectedToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastReflectionDate.year,
      lastReflectionDate.month,
      lastReflectionDate.day,
    );

    return lastDate.isAtSameMomentAs(today);
  }

  ReadingStreak copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReflectionDate,
    List<DateTime>? reflectionDates,
  }) {
    return ReadingStreak(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReflectionDate: lastReflectionDate ?? this.lastReflectionDate,
      reflectionDates: reflectionDates ?? this.reflectionDates,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingStreak &&
        other.userId == userId &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastReflectionDate == lastReflectionDate &&
        _listEquals(other.reflectionDates, reflectionDates);
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        currentStreak.hashCode ^
        longestStreak.hashCode ^
        lastReflectionDate.hashCode ^
        reflectionDates.hashCode;
  }

  @override
  String toString() {
    return 'ReadingStreak(userId: $userId, currentStreak: $currentStreak, longestStreak: $longestStreak, lastReflectionDate: $lastReflectionDate, reflectionDates: $reflectionDates)';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    if (identical(a, b)) return true;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}