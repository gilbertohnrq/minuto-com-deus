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

  int get totalDaysRead => reflectionDates.length;

  /// Create an empty ReadingStreak
  static ReadingStreak empty() {
    return ReadingStreak(
      userId: '',
      currentStreak: 0,
      longestStreak: 0,
      lastReflectionDate: DateTime.now(),
      reflectionDates: [],
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReflectionDate': lastReflectionDate.toIso8601String(),
      'reflectionDates': reflectionDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  /// Create from JSON for local storage
  static ReadingStreak fromJson(Map<String, dynamic> json) {
    return ReadingStreak(
      userId: json['userId'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastReflectionDate: DateTime.parse(json['lastReflectionDate'] ?? DateTime.now().toIso8601String()),
      reflectionDates: (json['reflectionDates'] as List<dynamic>?)
          ?.map((dateStr) => DateTime.parse(dateStr))
          .toList() ?? [],
    );
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