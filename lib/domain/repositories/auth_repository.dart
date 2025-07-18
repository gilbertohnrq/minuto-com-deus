import '../entities/user.dart';

abstract class AuthRepository {
  /// Get current authenticated user
  Future<User?> getCurrentUser();
  
  /// Sign in with email and password
  Future<User> signInWithEmail(String email, String password);
  
  /// Sign in with Google
  Future<User> signInWithGoogle();
  
  /// Register with email and password
  Future<User> registerWithEmail(String email, String password, String? name);
  
  /// Sign out current user
  Future<void> signOut();
  
  /// Stream of authentication state changes
  Stream<User?> authStateChanges();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
}