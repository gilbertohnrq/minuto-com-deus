/// Reading streak entity for tracking daily devotional reading habits
class ReadingStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReadDate;
  final Set<String> readDates; // ISO date strings (yyyy-MM-dd)
  final int totalDaysRead;
  final DateTime? streakStartDate;
  
  const ReadingStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastReadDate,
    required this.readDates,
    required this.totalDaysRead,
    this.streakStartDate,
  });
  
  /// Create an empty streak for new users
  factory ReadingStreak.empty() {
    return const ReadingStreak(
      currentStreak: 0,
      longestStreak: 0,
      lastReadDate: null,
      readDates: <String>{},
      totalDaysRead: 0,
      streakStartDate: null,
    );
  }
  
  /// Check if user has read today's devotional
  bool get hasReadToday {
    final today = DateTime.now();
    final todayString = _formatDateISO(today);
    return readDates.contains(todayString);
  }
  
  /// Check if streak is still active (read yesterday or today)
  bool get isStreakActive {
    if (lastReadDate == null) return false;
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    return _isSameDay(lastReadDate!, today) || 
           _isSameDay(lastReadDate!, yesterday);
  }
  
  /// Get days since last read
  int get daysSinceLastRead {
    if (lastReadDate == null) return 0;
    final today = DateTime.now();
    return today.difference(lastReadDate!).inDays;
  }
  
  /// Create a new streak after reading today's devotional
  ReadingStreak markAsRead(DateTime date) {
    final dateString = _formatDateISO(date);
    final today = DateTime.now();
    
    // If already read today, no changes
    if (readDates.contains(dateString)) return this;
    
    // Add date to read dates
    final newReadDates = Set<String>.from(readDates)..add(dateString);
    
    // Calculate new streak
    int newCurrentStreak = currentStreak;
    DateTime? newStreakStartDate = streakStartDate;
    
    if (lastReadDate == null) {
      // First read ever
      newCurrentStreak = 1;
      newStreakStartDate = date;
    } else {
      final daysSinceLastRead = today.difference(lastReadDate!).inDays;
      
      if (daysSinceLastRead == 1) {
        // Consecutive day - continue streak
        newCurrentStreak = currentStreak + 1;
      } else if (daysSinceLastRead > 1) {
        // Streak broken - start new streak
        newCurrentStreak = 1;
        newStreakStartDate = date;
      }
      // If same day (daysSinceLastRead == 0), keep current streak
    }
    
    return ReadingStreak(
      currentStreak: newCurrentStreak,
      longestStreak: newCurrentStreak > longestStreak ? newCurrentStreak : longestStreak,
      lastReadDate: date,
      readDates: newReadDates,
      totalDaysRead: totalDaysRead + 1,
      streakStartDate: newStreakStartDate,
    );
  }
  
  /// Get streak milestone info (for notifications)
  StreakMilestone? getStreakMilestone() {
    if (currentStreak == 0) return null;
    
    final milestones = [3, 7, 14, 30, 50, 100, 200, 365];
    
    for (final milestone in milestones) {
      if (currentStreak == milestone) {
        return StreakMilestone(
          days: milestone,
          message: _getMilestoneMessage(milestone),
        );
      }
    }
    
    return null;
  }
  
  ReadingStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    Set<String>? readDates,
    int? totalDaysRead,
    DateTime? streakStartDate,
  }) {
    return ReadingStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      readDates: readDates ?? this.readDates,
      totalDaysRead: totalDaysRead ?? this.totalDaysRead,
      streakStartDate: streakStartDate ?? this.streakStartDate,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingStreak &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastReadDate == lastReadDate &&
        other.readDates == readDates &&
        other.totalDaysRead == totalDaysRead &&
        other.streakStartDate == streakStartDate;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      currentStreak,
      longestStreak,
      lastReadDate,
      readDates,
      totalDaysRead,
      streakStartDate,
    );
  }
  
  @override
  String toString() {
    return 'ReadingStreak(current: $currentStreak, longest: $longestStreak, total: $totalDaysRead, hasReadToday: $hasReadToday)';
  }
  
  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReadDate': lastReadDate?.toIso8601String(),
      'readDates': readDates.toList(),
      'totalDaysRead': totalDaysRead,
      'streakStartDate': streakStartDate?.toIso8601String(),
    };
  }
  
  /// Create from JSON for local storage
  factory ReadingStreak.fromJson(Map<String, dynamic> json) {
    return ReadingStreak(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastReadDate: json['lastReadDate'] != null 
          ? DateTime.parse(json['lastReadDate']) 
          : null,
      readDates: Set<String>.from(json['readDates'] ?? []),
      totalDaysRead: json['totalDaysRead'] ?? 0,
      streakStartDate: json['streakStartDate'] != null 
          ? DateTime.parse(json['streakStartDate']) 
          : null,
    );
  }
  
  // Helper methods
  String _formatDateISO(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  String _getMilestoneMessage(int milestone) {
    switch (milestone) {
      case 3:
        return 'Parabéns! 3 dias seguidos lendo 🙏';
      case 7:
        return 'Incrível! Uma semana de leitura diária 📖';
      case 14:
        return 'Fantástico! Duas semanas de dedicação 🌟';
      case 30:
        return 'Uau! Um mês inteiro de leitura 🎉';
      case 50:
        return 'Excelente! 50 dias de crescimento espiritual 💪';
      case 100:
        return 'Extraordinário! 100 dias de fé e dedicação 🏆';
      case 200:
        return 'Fenomenal! 200 dias de jornada espiritual 👑';
      case 365:
        return 'Milagroso! Um ano completo de leitura diária 🌈';
      default:
        return 'Continue assim! Cada dia conta 💝';
    }
  }
}

/// Streak milestone information
class StreakMilestone {
  final int days;
  final String message;
  
  const StreakMilestone({
    required this.days,
    required this.message,
  });
  
  @override
  String toString() => 'StreakMilestone(days: $days, message: $message)';
}