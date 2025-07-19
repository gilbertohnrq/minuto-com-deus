import '../../domain/entities/reflection.dart';
import '../../domain/repositories/reflection_repository.dart';
import '../datasources/local/reflection_local_datasource.dart';
import '../models/reflection_model.dart';

class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionLocalDataSource _localDataSource;

  ReflectionRepositoryImpl({
    required ReflectionLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<void> saveReflection(Reflection reflection) async {
    final model = ReflectionModel.fromEntity(reflection);
    await _localDataSource.saveReflection(model);
  }

  @override
  Future<Reflection?> getReflection(String devotionalId, String userId) async {
    final model = await _localDataSource.getReflection(devotionalId, userId);
    return model?.toEntity();
  }

  @override
  Future<List<Reflection>> getUserReflections(String userId, {int? limit}) async {
    final models = await _localDataSource.getUserReflections(userId, limit: limit);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateReflection(Reflection reflection) async {
    final model = ReflectionModel.fromEntity(reflection);
    await _localDataSource.updateReflection(model);
  }

  @override
  Future<void> deleteReflection(String reflectionId) async {
    await _localDataSource.deleteReflection(reflectionId);
  }

  @override
  Future<bool> hasReflectedOnDate(String userId, DateTime date) async {
    return await _localDataSource.hasReflectedOnDate(userId, date);
  }

  @override
  Future<List<Reflection>> getReflectionsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await _localDataSource.getReflectionsInDateRange(
      userId,
      startDate,
      endDate,
    );
    return models.map((model) => model.toEntity()).toList();
  }
}