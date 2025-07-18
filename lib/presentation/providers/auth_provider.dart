import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../services/auth_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for UserRemoteDataSource
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl();
});

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthRepositoryImpl(
    authService: authService,
    userRepository: userRepository,
  );
});

/// Provider that watches authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Provider for the current user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for user display name
final userDisplayNameProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.name,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is premium
final isPremiumUserProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.isPremium ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for authentication operations
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Authentication state
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Register with email and password
  Future<void> registerWithEmail(
      String email, String password, String? name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user =
          await _authRepository.registerWithEmail(email, password, name);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.signOut();
      state = state.copyWith(isLoading: false, user: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
