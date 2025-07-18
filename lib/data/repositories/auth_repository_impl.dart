import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final UserRepository _userRepository;

  AuthRepositoryImpl({
    required AuthService authService,
    required UserRepository userRepository,
  }) : _authService = authService,
       _userRepository = userRepository;

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _authService.getCurrentUser();
      if (firebaseUser == null) return null;
      
      // Try to get user profile from Firestore first
      try {
        return await _userRepository.getUserProfile(firebaseUser.uid);
      } catch (e) {
        // If user profile doesn't exist in Firestore, return mapped Firebase user
        return _mapFirebaseUserToUser(firebaseUser);
      }
    } catch (e) {
      throw AuthException('Erro ao obter usuário atual: ${e.toString()}', 'get_current_user_error');
    }
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _authService.signInWithEmail(email, password);
      final firebaseUser = credential.user;
      
      if (firebaseUser == null) {
        throw const AuthException('Falha na autenticação', 'authentication_failed');
      }
      
      // Try to get user profile from Firestore
      try {
        return await _userRepository.getUserProfile(firebaseUser.uid);
      } catch (e) {
        // If user profile doesn't exist in Firestore, return mapped Firebase user
        return _mapFirebaseUserToUser(firebaseUser);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro durante login: ${e.toString()}', 'sign_in_error');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      final firebaseUser = credential.user;
      
      if (firebaseUser == null) {
        throw const AuthException('Falha na autenticação com Google', 'google_authentication_failed');
      }
      
      // Check if this is a new user (first time signing in)
      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
      
      final userEntity = _mapFirebaseUserToUser(firebaseUser);
      
      // Create user profile in Firestore for new users
      if (isNewUser) {
        try {
          return await _userRepository.createUserProfile(userEntity);
        } catch (e) {
          // If user profile creation fails, we should still return the user
          // but log the error for debugging
          // TODO: Replace with proper logging in production
          // print('Warning: Failed to create user profile in Firestore: $e');
          return userEntity;
        }
      } else {
        // Try to get existing user profile from Firestore
        try {
          return await _userRepository.getUserProfile(firebaseUser.uid);
        } catch (e) {
          // If user profile doesn't exist in Firestore, return mapped Firebase user
          return userEntity;
        }
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro durante login com Google: ${e.toString()}', 'google_sign_in_error');
    }
  }

  @override
  Future<User> registerWithEmail(String email, String password, String? name) async {
    try {
      final credential = await _authService.createUserWithEmail(email, password);
      final firebaseUser = credential.user;
      
      if (firebaseUser == null) {
        throw const AuthException('Falha no registro', 'registration_failed');
      }
      
      // Update display name if provided
      if (name != null && name.isNotEmpty) {
        await firebaseUser.updateDisplayName(name);
        await firebaseUser.reload();
      }
      
      // Create user profile in Firestore
      final userEntity = _mapFirebaseUserToUser(firebaseUser);
      
      try {
        return await _userRepository.createUserProfile(userEntity);
      } catch (e) {
        // If user profile creation fails, we should still return the user
        // but log the error for debugging
        // TODO: Replace with proper logging in production
        // print('Warning: Failed to create user profile in Firestore: $e');
        return userEntity;
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro durante registro: ${e.toString()}', 'registration_error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro durante logout: ${e.toString()}', 'sign_out_error');
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _authService.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return _mapFirebaseUserToUser(firebaseUser);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro ao enviar email de recuperação: ${e.toString()}', 'password_reset_error');
    }
  }

  /// Maps Firebase User to domain User entity
  User _mapFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName,
      isPremium: false, // Default to false, will be updated from Firestore in later tasks
      notificationSettings: NotificationSettings.defaultSettings(),
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }
}