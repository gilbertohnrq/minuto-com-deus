import '../../domain/entities/reading_streak.dart';
import '../../domain/repositories/reading_streak_repository.dart';
import '../datasources/local/reading_streak_local_datasource.dart';
import '../models/reading_streak_model.dart';

class ReadingStreakRepositoryImpl implements ReadingStreakRepository {
  final ReadingStreakLocalDataSource _localDataSource;

  ReadingStreakRepositoryImpl({
    required ReadingStreakLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<ReadingStreak> getUserStreak(String userId) async {
    final model = await _localDataSource.getUserStreak(userId);
    return model.toEntity();
  }

  @override
  Future<void> updateStreak(ReadingStreak streak) async {
    final model = ReadingStreakModel.fromEntity(streak);
    await _localDataSource.updateStreak(model);
  }

  @override
  Future<ReadingStreak> incrementStreak(String userId, DateTime reflectionDate) async {
    final model = await _localDataSource.incrementStreak(userId, reflectionDate);
    return model.toEntity();
  }

  @override
  Future<void> resetStreak(String userId) async {
    await _localDataSource.resetStreak(userId);
  }

  @override
  Future<bool> shouldResetStreak(String userId) async {
    return await _localDataSource.shouldResetStreak(userId);
  }

  @override
  List<int> getStreakMilestones() {
    return [7, 30, 100];
  }

  @override
  bool isStreakMilestone(int streak) {
    return getStreakMilestones().contains(streak);
  }
}