import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reflection_model.dart';

abstract class ReflectionLocalDataSource {
  Future<void> saveReflection(ReflectionModel reflection);
  Future<ReflectionModel?> getReflection(String devotionalId, String userId);
  Future<List<ReflectionModel>> getUserReflections(String userId, {int? limit});
  Future<void> updateReflection(ReflectionModel reflection);
  Future<void> deleteReflection(String reflectionId);
  Future<bool> hasReflectedOnDate(String userId, DateTime date);
  Future<List<ReflectionModel>> getReflectionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}

class ReflectionLocalDataSourceImpl implements ReflectionLocalDataSource {
  static const String _reflectionsKey = 'reflections';
  static const String _userReflectionsPrefix = 'user_reflections_';

  @override
  Future<void> saveReflection(ReflectionModel reflection) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save to general reflections
    final reflectionsJson = prefs.getString(_reflectionsKey) ?? '{}';
    final reflections = Map<String, dynamic>.from(jsonDecode(reflectionsJson));
    reflections[reflection.id] = reflection.toJson();
    await prefs.setString(_reflectionsKey, jsonEncode(reflections));

    // Save to user-specific reflections for faster lookup
    final userKey = '$_userReflectionsPrefix${reflection.userId}';
    final userReflectionsJson = prefs.getString(userKey) ?? '[]';
    final userReflections = List<dynamic>.from(jsonDecode(userReflectionsJson));
    
    // Remove existing reflection with same devotionalId if exists
    userReflections.removeWhere((r) => r['devotionalId'] == reflection.devotionalId);
    userReflections.add(reflection.toJson());
    
    // Sort by createdAt descending
    userReflections.sort((a, b) => 
      DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    
    await prefs.setString(userKey, jsonEncode(userReflections));
  }

  @override
  Future<ReflectionModel?> getReflection(String devotionalId, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = '$_userReflectionsPrefix$userId';
    final userReflectionsJson = prefs.getString(userKey) ?? '[]';
    final userReflections = List<dynamic>.from(jsonDecode(userReflectionsJson));

    for (final reflectionJson in userReflections) {
      if (reflectionJson['devotionalId'] == devotionalId) {
        return ReflectionModel.fromJson(reflectionJson);
      }
    }

    return null;
  }

  @override
  Future<List<ReflectionModel>> getUserReflections(String userId, {int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = '$_userReflectionsPrefix$userId';
    final userReflectionsJson = prefs.getString(userKey) ?? '[]';
    final userReflections = List<dynamic>.from(jsonDecode(userReflectionsJson));

    final reflections = userReflections
        .map((json) => ReflectionModel.fromJson(json))
        .toList();

    if (limit != null && reflections.length > limit) {
      return reflections.take(limit).toList();
    }

    return reflections;
  }

  @override
  Future<void> updateReflection(ReflectionModel reflection) async {
    // Update is the same as save for local storage
    await saveReflection(reflection);
  }

  @override
  Future<void> deleteReflection(String reflectionId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove from general reflections
    final reflectionsJson = prefs.getString(_reflectionsKey) ?? '{}';
    final reflections = Map<String, dynamic>.from(jsonDecode(reflectionsJson));
    final reflection = reflections[reflectionId];
    
    if (reflection != null) {
      reflections.remove(reflectionId);
      await prefs.setString(_reflectionsKey, jsonEncode(reflections));

      // Remove from user-specific reflections
      final userId = reflection['userId'];
      final userKey = '$_userReflectionsPrefix$userId';
      final userReflectionsJson = prefs.getString(userKey) ?? '[]';
      final userReflections = List<dynamic>.from(jsonDecode(userReflectionsJson));
      
      userReflections.removeWhere((r) => r['id'] == reflectionId);
      await prefs.setString(userKey, jsonEncode(userReflections));
    }
  }

  @override
  Future<bool> hasReflectedOnDate(String userId, DateTime date) async {
    final reflections = await getUserReflections(userId);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return reflections.any((reflection) {
      final reflectionDate = DateTime(
        reflection.createdAt.year,
        reflection.createdAt.month,
        reflection.createdAt.day,
      );
      return reflectionDate.isAtSameMomentAs(targetDate);
    });
  }

  @override
  Future<List<ReflectionModel>> getReflectionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final reflections = await getUserReflections(userId);
    
    return reflections.where((reflection) {
      return reflection.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          reflection.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }
}