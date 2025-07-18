import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Create a new user profile in Firestore
  Future<UserModel> createUser(UserModel user);
  
  /// Get user profile by ID
  Future<UserModel> getUser(String userId);
  
  /// Update user profile
  Future<UserModel> updateUser(UserModel user);
  
  /// Delete user profile
  Future<void> deleteUser(String userId);
  
  /// Check if user exists
  Future<bool> userExists(String userId);
  
  /// Update premium status
  Future<void> updatePremiumStatus(String userId, bool isPremium);
  
  /// Update notification settings
  Future<void> updateNotificationSettings(String userId, Map<String, dynamic> settings);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';
  
  UserRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(user.id);
      
      // Check if user already exists
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        throw const UserDataException('Usuário já existe');
      }
      
      // Create user document
      await docRef.set(user.toFirestore());
      
      // Return the created user
      final createdDoc = await docRef.get();
      return UserModel.fromFirestore(createdDoc);
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao criar usuário: ${e.message}');
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro inesperado ao criar usuário: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> getUser(String userId) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw const UserDataException('Usuário não encontrado');
      }
      
      return UserModel.fromFirestore(docSnapshot);
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao buscar usuário: ${e.message}');
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro inesperado ao buscar usuário: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(user.id);
      
      // Check if user exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw const UserDataException('Usuário não encontrado para atualização');
      }
      
      // Update user document with timestamp
      final updatedUser = user.copyWith(updatedAt: Timestamp.now());
      await docRef.update(updatedUser.toFirestore());
      
      // Return the updated user
      final updatedDoc = await docRef.get();
      return UserModel.fromFirestore(updatedDoc);
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao atualizar usuário: ${e.message}');
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro inesperado ao atualizar usuário: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteUser(String userId) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      
      // Check if user exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw const UserDataException('Usuário não encontrado para exclusão');
      }
      
      await docRef.delete();
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao excluir usuário: ${e.message}');
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro inesperado ao excluir usuário: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> userExists(String userId) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      final docSnapshot = await docRef.get();
      return docSnapshot.exists;
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao verificar existência do usuário: ${e.message}');
    } catch (e) {
      throw UserDataException('Erro inesperado ao verificar usuário: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updatePremiumStatus(String userId, bool isPremium) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      
      // Check if user exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw const UserDataException('Usuário não encontrado para atualização de status premium');
      }
      
      await docRef.update({
        'isPremium': isPremium,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao atualizar status premium: ${e.message}');
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro inesperado ao atualizar status premium: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateNotificationSettings(String userId, Map<String, dynamic> settings) async {
    try {
      final docRef = _firestore.collection(_usersCollection).doc(userId);
      
      // Check if user exists
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw const UserDataException('Usuário não encontrado para atualização de configurações');
      }
      
      await docRef.update({
        'notificationSettings': settings,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw UserDataException('Erro ao atualizar configurações de notificação: ${e.message}');
    } catch (e) {
      if (e is UserDataException) rethrow;
      throw UserDataException('Erro inesperado ao atualizar configurações: ${e.toString()}');
    }
  }
}