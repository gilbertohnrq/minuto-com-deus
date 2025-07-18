import '../../domain/entities/user.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../models/user_model.dart';
import '../../core/errors/exceptions.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  
  // Simple in-memory cache for user profiles
  final Map<String, User> _userCache = {};
  
  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<User> getUserProfile(String userId) async {
    try {
      // Check cache first
      if (_userCache.containsKey(userId)) {
        return _userCache[userId]!;
      }
      
      // Fetch from remote data source
      final userModel = await _remoteDataSource.getUser(userId);
      final user = userModel.toEntity();
      
      // Cache the result
      _userCache[userId] = user;
      
      return user;
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao buscar perfil do usuário: ${e.toString()}');
    }
  }

  @override
  Future<User> updateUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUserModel = await _remoteDataSource.updateUser(userModel);
      final updatedUser = updatedUserModel.toEntity();
      
      // Update cache
      _userCache[user.id] = updatedUser;
      
      return updatedUser;
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao atualizar perfil do usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> updateNotificationSettings(String userId, NotificationSettings settings) async {
    try {
      await _remoteDataSource.updateNotificationSettings(userId, settings.toMap());
      
      // Update cache if user is cached
      if (_userCache.containsKey(userId)) {
        final cachedUser = _userCache[userId]!;
        _userCache[userId] = cachedUser.copyWith(notificationSettings: settings);
      }
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao atualizar configurações de notificação: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePremiumStatus(String userId, bool isPremium) async {
    try {
      await _remoteDataSource.updatePremiumStatus(userId, isPremium);
      
      // Update cache if user is cached
      if (_userCache.containsKey(userId)) {
        final cachedUser = _userCache[userId]!;
        _userCache[userId] = cachedUser.copyWith(isPremium: isPremium);
      }
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao atualizar status premium: ${e.toString()}');
    }
  }

  @override
  Future<bool> userExists(String userId) async {
    try {
      // Check cache first
      if (_userCache.containsKey(userId)) {
        return true;
      }
      
      return await _remoteDataSource.userExists(userId);
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao verificar existência do usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      
      // Remove from cache
      _userCache.remove(userId);
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao excluir perfil do usuário: ${e.toString()}');
    }
  }

  @override
  Future<User> createUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUserModel = await _remoteDataSource.createUser(userModel);
      final createdUser = createdUserModel.toEntity();
      
      // Cache the created user
      _userCache[user.id] = createdUser;
      
      return createdUser;
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro ao criar perfil do usuário: ${e.toString()}');
    }
  }
  
  /// Clear the user cache (useful for logout or testing)
  void clearCache() {
    _userCache.clear();
  }
  
  /// Get cached user if available (useful for offline scenarios)
  User? getCachedUser(String userId) {
    return _userCache[userId];
  }
}