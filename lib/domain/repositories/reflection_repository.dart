import '../entities/reflection.dart';

abstract class ReflectionRepository {
  /// Save a new reflection
  Future<void> saveReflection(Reflection reflection);

  /// Get a reflection for a specific devotional and user
  Future<Reflection?> getReflection(String devotionalId, String userId);

  /// Get all reflections for a user
  Future<List<Reflection>> getUserReflections(String userId, {int? limit});

  /// Update an existing reflection
  Future<void> updateReflection(Reflection reflection);

  /// Delete a reflection
  Future<void> deleteReflection(String reflectionId);

  /// Check if user has reflected on a specific date
  Future<bool> hasReflectedOnDate(String userId, DateTime date);

  /// Get reflections for a specific date range
  Future<List<Reflection>> getReflectionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}