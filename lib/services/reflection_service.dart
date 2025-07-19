import '../domain/entities/reflection.dart';
import '../domain/repositories/reflection_repository.dart';

class ReflectionService {
  final ReflectionRepository _reflectionRepository;

  ReflectionService({
    required ReflectionRepository reflectionRepository,
  }) : _reflectionRepository = reflectionRepository;

  /// Save a new reflection for a devotional
  Future<void> saveReflection(
    String devotionalId,
    String userId,
    String content,
  ) async {
    final now = DateTime.now();
    final reflection = Reflection(
      id: '${devotionalId}_${userId}_${now.millisecondsSinceEpoch}',
      devotionalId: devotionalId,
      userId: userId,
      content: content.trim(),
      createdAt: now,
    );

    await _reflectionRepository.saveReflection(reflection);
  }

  /// Get reflection for a specific devotional
  Future<Reflection?> getReflection(String devotionalId, String userId) async {
    return await _reflectionRepository.getReflection(devotionalId, userId);
  }

  /// Update an existing reflection
  Future<void> updateReflection(String reflectionId, String content) async {
    // First get the existing reflection to preserve other fields
    final userReflections = await _reflectionRepository.getUserReflections(
      '', // We'll need to modify this to get by ID
      limit: 1000, // Get all to find the one with matching ID
    );

    final existingReflection = userReflections
        .where((r) => r.id == reflectionId)
        .firstOrNull;

    if (existingReflection != null) {
      final updatedReflection = existingReflection.copyWith(
        content: content.trim(),
        updatedAt: DateTime.now(),
      );

      await _reflectionRepository.updateReflection(updatedReflection);
    }
  }

  /// Get all reflections for a user
  Future<List<Reflection>> getUserReflections(String userId, {int? limit}) async {
    return await _reflectionRepository.getUserReflections(userId, limit: limit);
  }

  /// Check if user has reflected today
  Future<bool> hasReflectedToday(String userId) async {
    final today = DateTime.now();
    return await _reflectionRepository.hasReflectedOnDate(userId, today);
  }

  /// Get reflections for the current week
  Future<List<Reflection>> getWeeklyReflections(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await _reflectionRepository.getReflectionsInDateRange(
      userId,
      startOfWeek,
      endOfWeek,
    );
  }

  /// Get reflections for the current month
  Future<List<Reflection>> getMonthlyReflections(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return await _reflectionRepository.getReflectionsInDateRange(
      userId,
      startOfMonth,
      endOfMonth,
    );
  }

  /// Delete a reflection
  Future<void> deleteReflection(String reflectionId) async {
    await _reflectionRepository.deleteReflection(reflectionId);
  }

  /// Validate reflection content
  bool isValidReflectionContent(String content) {
    final trimmed = content.trim();
    return trimmed.isNotEmpty && trimmed.length >= 10 && trimmed.length <= 1000;
  }

  /// Get reflection content validation error message
  String? getValidationError(String content) {
    final trimmed = content.trim();
    
    if (trimmed.isEmpty) {
      return 'Por favor, adicione sua reflexão';
    }
    
    if (trimmed.length < 10) {
      return 'Sua reflexão deve ter pelo menos 10 caracteres';
    }
    
    if (trimmed.length > 1000) {
      return 'Sua reflexão deve ter no máximo 1000 caracteres';
    }
    
    return null;
  }
}