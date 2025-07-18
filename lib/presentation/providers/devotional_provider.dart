import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/exceptions.dart';
import '../../data/datasources/local/devotional_local_datasource.dart';
import '../../data/repositories/devotional_repository_impl.dart';
import '../../domain/entities/devotional.dart';
import '../../domain/repositories/devotional_repository.dart';

/// Provider for DevotionalLocalDataSource
final devotionalLocalDataSourceProvider =
    Provider<DevotionalLocalDataSource>((ref) {
  return DevotionalLocalDataSourceImpl();
});

/// Provider for DevotionalRepository
final devotionalRepositoryProvider = Provider<DevotionalRepository>((ref) {
  final localDataSource = ref.watch(devotionalLocalDataSourceProvider);
  return DevotionalRepositoryImpl(localDataSource: localDataSource);
});

/// Provider for today's devotional
final todayDevotionalProvider = FutureProvider<Devotional?>((ref) async {
  final repository = ref.watch(devotionalRepositoryProvider);
  final today = DateTime.now();

  // Debug logging
  print('🐛 DEBUG: Current date: $today');
  print(
      '🐛 DEBUG: Today formatted for search: ${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}');

  // Let's also debug what dates are available in the JSON
  try {
    final String jsonString =
        await rootBundle.loadString('assets/data/devocionais.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    print('🐛 DEBUG: Total devotionals in JSON: ${jsonList.length}');

    // Show first few dates to see format
    for (int i = 0; i < math.min(5, jsonList.length); i++) {
      final item = jsonList[i] as Map<String, dynamic>;
      print('🐛 DEBUG: Sample date $i: ${item['data']}');
    }

    // Check if today's date exists
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todaysData =
        jsonList.where((item) => item['data'] == todayString).toList();
    print('🐛 DEBUG: Found ${todaysData.length} entries for $todayString');

    if (todaysData.isNotEmpty) {
      print('🐛 DEBUG: Today\'s devotional data: ${todaysData.first}');
    }

    // Also check July dates
    final julyData = jsonList
        .where((item) => item['data'].toString().startsWith('2025-07'))
        .toList();
    print('🐛 DEBUG: Found ${julyData.length} entries for July 2025');
  } catch (jsonError) {
    print('🐛 DEBUG: Error reading JSON directly: $jsonError');
  }

  try {
    final result = await repository.getDailyDevotional(today);
    print('🐛 DEBUG: Devotional found: ${result != null}');
    if (result != null) {
      print('🐛 DEBUG: Devotional verse: ${result.verse}');
    }
    return result;
  } catch (e) {
    print('🐛 DEBUG: Error loading devotional: $e');
    if (e is DevotionalNotFoundException) {
      // Return null for missing devotionals instead of throwing
      return null;
    }
    rethrow;
  }
});

/// Provider for devotional by specific date
final devotionalByDateProvider =
    FutureProvider.family<Devotional?, DateTime>((ref, date) async {
  final repository = ref.watch(devotionalRepositoryProvider);

  try {
    return await repository.getDailyDevotional(date);
  } catch (e) {
    if (e is DevotionalNotFoundException) {
      // Return null for missing devotionals instead of throwing
      return null;
    }
    rethrow;
  }
});

/// Provider for devotional history
final devotionalHistoryProvider =
    FutureProvider.family<List<Devotional>, int>((ref, limit) async {
  final repository = ref.watch(devotionalRepositoryProvider);
  return await repository.getDevotionalHistory(limit);
});

/// Provider for all devotionals
final allDevotionalsProvider = FutureProvider<List<Devotional>>((ref) async {
  final repository = ref.watch(devotionalRepositoryProvider);
  return await repository.getAllDevotionals();
});

/// State class for devotional operations
class DevotionalState {
  final bool isLoading;
  final String? errorMessage;
  final Devotional? currentDevotional;
  final List<Devotional> history;

  const DevotionalState({
    this.isLoading = false,
    this.errorMessage,
    this.currentDevotional,
    this.history = const [],
  });

  DevotionalState copyWith({
    bool? isLoading,
    String? errorMessage,
    Devotional? currentDevotional,
    List<Devotional>? history,
  }) {
    return DevotionalState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentDevotional: currentDevotional ?? this.currentDevotional,
      history: history ?? this.history,
    );
  }
}

/// Devotional state notifier for complex operations
class DevotionalNotifier extends StateNotifier<DevotionalState> {
  final DevotionalRepository _repository;

  DevotionalNotifier(this._repository) : super(const DevotionalState());

  /// Load today's devotional
  Future<void> loadTodayDevotional() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final today = DateTime.now();
      final devotional = await _repository.getDailyDevotional(today);
      state = state.copyWith(
        isLoading: false,
        currentDevotional: devotional,
      );
    } catch (e) {
      String errorMessage;
      if (e is DevotionalNotFoundException) {
        errorMessage = 'Em breve teremos um devocional para este dia';
      } else {
        errorMessage = 'Erro ao carregar devocional: ${e.toString()}';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        currentDevotional: null,
      );
    }
  }

  /// Load devotional for specific date
  Future<void> loadDevotionalByDate(DateTime date) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final devotional = await _repository.getDailyDevotional(date);
      state = state.copyWith(
        isLoading: false,
        currentDevotional: devotional,
      );
    } catch (e) {
      String errorMessage;
      if (e is DevotionalNotFoundException) {
        errorMessage = 'Em breve teremos um devocional para este dia';
      } else {
        errorMessage = 'Erro ao carregar devocional: ${e.toString()}';
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        currentDevotional: null,
      );
    }
  }

  /// Refresh current devotional
  Future<void> refreshDevotional() async {
    await loadTodayDevotional();
  }

  /// Load devotional history
  Future<void> loadHistory({int limit = 30}) async {
    try {
      final history = await _repository.getDevotionalHistory(limit);
      state = state.copyWith(history: history);
    } catch (e) {
      // Don't update error state for history loading failures
      // as it's not critical for the main functionality
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear current devotional
  void clearCurrentDevotional() {
    state = state.copyWith(currentDevotional: null);
  }
}

/// Provider for devotional state notifier
final devotionalNotifierProvider =
    StateNotifierProvider<DevotionalNotifier, DevotionalState>((ref) {
  final repository = ref.watch(devotionalRepositoryProvider);
  return DevotionalNotifier(repository);
});

/// Convenience provider to check if today's devotional is available
final hasTodayDevotionalProvider = Provider<bool>((ref) {
  final todayDevotional = ref.watch(todayDevotionalProvider);
  return todayDevotional.when(
    data: (devotional) => devotional != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for formatted today's date
final todayDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
});
