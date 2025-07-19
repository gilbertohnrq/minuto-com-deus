import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/reflection_local_datasource.dart';
import '../../data/repositories/reflection_repository_impl.dart';
import '../../domain/entities/reflection.dart';
import '../../domain/repositories/reflection_repository.dart';
import '../../services/reflection_service.dart';
import 'auth_provider.dart';

// Data source provider
final reflectionLocalDataSourceProvider = Provider<ReflectionLocalDataSource>((ref) {
  return ReflectionLocalDataSourceImpl();
});

// Repository provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final localDataSource = ref.watch(reflectionLocalDataSourceProvider);
  return ReflectionRepositoryImpl(localDataSource: localDataSource);
});

// Service provider
final reflectionServiceProvider = Provider<ReflectionService>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return ReflectionService(reflectionRepository: repository);
});

// Current user's reflection for today's devotional
final todayReflectionProvider = FutureProvider.family<Reflection?, String>((ref, devotionalId) async {
  final reflectionService = ref.watch(reflectionServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await reflectionService.getReflection(devotionalId, user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// User's all reflections
final userReflectionsProvider = FutureProvider<List<Reflection>>((ref) async {
  final reflectionService = ref.watch(reflectionServiceProvider);
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return [];
      return await reflectionService.getUserReflections(user.uid);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Note: hasReflectedTodayProvider is defined in reading_streak_provider.dart

// Reflection submission state notifier
class ReflectionSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  ReflectionSubmissionNotifier(this._reflectionService, this._ref) : super(const AsyncValue.data(null));

  final ReflectionService _reflectionService;
  final Ref _ref;

  Future<void> saveReflection(String devotionalId, String content) async {
    final authState = _ref.read(authStateProvider);
    
    await authState.when(
      data: (user) async {
        if (user == null) {
          state = AsyncValue.error('User not authenticated', StackTrace.current);
          return;
        }

        state = const AsyncValue.loading();
        
        try {
          await _reflectionService.saveReflection(devotionalId, user.uid, content);
          state = const AsyncValue.data(null);
          
          // Invalidate related providers to refresh UI
          _ref.invalidate(todayReflectionProvider(devotionalId));
          _ref.invalidate(userReflectionsProvider);
        } catch (error, stackTrace) {
          state = AsyncValue.error(error, stackTrace);
        }
      },
      loading: () async {
        state = AsyncValue.error('Authentication loading', StackTrace.current);
      },
      error: (error, stackTrace) async {
        state = AsyncValue.error('Authentication error: $error', stackTrace);
      },
    );
  }

  String? validateContent(String content) {
    return _reflectionService.getValidationError(content);
  }
}

// Reflection submission provider
final reflectionSubmissionProvider = StateNotifierProvider<ReflectionSubmissionNotifier, AsyncValue<void>>((ref) {
  final reflectionService = ref.watch(reflectionServiceProvider);
  return ReflectionSubmissionNotifier(reflectionService, ref);
});