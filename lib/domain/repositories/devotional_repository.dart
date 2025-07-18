import '../entities/devotional.dart';

abstract class DevotionalRepository {
  /// Get devotional for a specific date
  Future<Devotional?> getDailyDevotional(DateTime date);
  
  /// Get devotional history with limit
  Future<List<Devotional>> getDevotionalHistory(int limit);
  
  /// Cache devotionals locally
  Future<void> cacheDevotionals(List<Devotional> devotionals);
  
  /// Get all available devotionals
  Future<List<Devotional>> getAllDevotionals();
}