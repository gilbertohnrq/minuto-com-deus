import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/errors/exceptions.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Initialize the auth service
  Future<void> initialize() async {
    // Any initialization logic if needed
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erro inesperado durante o login: ${e.toString()}', 'unknown_error');
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw AuthException('Login com Google cancelado pelo usuário', 'google_sign_in_cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erro durante login com Google: ${e.toString()}', 'google_sign_in_error');
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erro inesperado durante o registro: ${e.toString()}', 'unknown_error');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Erro durante logout: ${e.toString()}', 'sign_out_error');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Erro ao enviar email de recuperação: ${e.toString()}', 'password_reset_error');
    }
  }

  /// Handle Firebase Auth exceptions and convert to custom exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('Usuário não encontrado', 'user_not_found');
      case 'wrong-password':
        return const AuthException('Senha incorreta', 'wrong_password');
      case 'email-already-in-use':
        return const AuthException('Este email já está em uso', 'email_already_in_use');
      case 'weak-password':
        return const AuthException('A senha deve ter pelo menos 6 caracteres', 'weak_password');
      case 'invalid-email':
        return const AuthException('Email inválido', 'invalid_email');
      case 'user-disabled':
        return const AuthException('Esta conta foi desabilitada', 'user_disabled');
      case 'too-many-requests':
        return const AuthException('Muitas tentativas. Tente novamente mais tarde', 'too_many_requests');
      case 'operation-not-allowed':
        return const AuthException('Operação não permitida', 'operation_not_allowed');
      case 'invalid-credential':
        return const AuthException('Credenciais inválidas', 'invalid_credential');
      case 'account-exists-with-different-credential':
        return const AuthException('Já existe uma conta com este email usando um método diferente', 'account_exists_with_different_credential');
      case 'invalid-verification-code':
        return const AuthException('Código de verificação inválido', 'invalid_verification_code');
      case 'invalid-verification-id':
        return const AuthException('ID de verificação inválido', 'invalid_verification_id');
      default:
        return AuthException('Erro de autenticação: ${e.message}', e.code);
    }
  }
}