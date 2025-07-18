import '../../domain/entities/devotional.dart';
import '../../domain/repositories/devotional_repository.dart';
import '../datasources/local/devotional_local_datasource.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/date_utils.dart';

class DevotionalRepositoryImpl implements DevotionalRepository {
  final DevotionalLocalDataSource localDataSource;
  
  // In-memory cache for devotionals
  List<Devotional>? _cachedDevotionals;
  DateTime? _lastCacheTime;
  static const Duration _cacheExpiry = Duration(hours: 24);

  DevotionalRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Devotional?> getDailyDevotional(DateTime date) async {
    try {
      final dateString = DateUtils.formatDateISO(date);
      
      // Try to get from local data source first
      final devotionalModel = await localDataSource.getDevotionalByDate(dateString);
      
      if (devotionalModel != null) {
        final devotional = devotionalModel.toEntity();
        
        // Cache this devotional
        await _addToCache(devotional);
        
        return devotional;
      }
      
      // If not found in local data source, check cache
      final cachedDevotional = await _getFromCache(date);
      if (cachedDevotional != null) {
        return cachedDevotional;
      }
      
      // If still not found, throw exception
      throw DevotionalNotFoundException(dateString);
      
    } catch (e) {
      if (e is DevotionalNotFoundException) {
        rethrow;
      }
      throw DataSourceException('Failed to get daily devotional: $e');
    }
  }

  @override
  Future<List<Devotional>> getDevotionalHistory(int limit) async {
    try {
      final devotionals = await getAllDevotionals();
      
      // Sort by date descending (most recent first)
      devotionals.sort((a, b) => b.date.compareTo(a.date));
      
      // Return limited results
      return devotionals.take(limit).toList();
      
    } catch (e) {
      throw DataSourceException('Failed to get devotional history: $e');
    }
  }

  @override
  Future<void> cacheDevotionals(List<Devotional> devotionals) async {
    try {
      _cachedDevotionals = List.from(devotionals);
      _lastCacheTime = DateTime.now();
    } catch (e) {
      throw StorageException('Failed to cache devotionals: $e');
    }
  }

  @override
  Future<List<Devotional>> getAllDevotionals() async {
    try {
      // Check if cache is valid
      if (_isCacheValid()) {
        return _cachedDevotionals!;
      }
      
      // Load from local data source
      final devotionalModels = await localDataSource.loadDevotionals();
      final devotionals = devotionalModels
          .map((model) => model.toEntity())
          .toList();
      
      // Cache the results
      await cacheDevotionals(devotionals);
      
      return devotionals;
      
    } catch (e) {
      throw DataSourceException('Failed to get all devotionals: $e');
    }
  }

  /// Check if the current cache is still valid
  bool _isCacheValid() {
    if (_cachedDevotionals == null || _lastCacheTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    final cacheAge = now.difference(_lastCacheTime!);
    
    return cacheAge < _cacheExpiry;
  }

  /// Get devotional from cache by date
  Future<Devotional?> _getFromCache(DateTime date) async {
    if (!_isCacheValid()) {
      return null;
    }
    
    try {
      final devotionals = _cachedDevotionals!;
      
      for (final devotional in devotionals) {
        if (DateUtils.isSameDay(devotional.date, date)) {
          return devotional;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add a single devotional to cache
  Future<void> _addToCache(Devotional devotional) async {
    try {
      if (_cachedDevotionals == null) {
        _cachedDevotionals = [devotional];
        _lastCacheTime = DateTime.now();
        return;
      }
      
      // Check if devotional already exists in cache
      final existingIndex = _cachedDevotionals!.indexWhere(
        (cached) => DateUtils.isSameDay(cached.date, devotional.date),
      );
      
      if (existingIndex != -1) {
        // Update existing devotional
        _cachedDevotionals![existingIndex] = devotional;
      } else {
        // Add new devotional
        _cachedDevotionals!.add(devotional);
      }
      
      _lastCacheTime = DateTime.now();
    } catch (e) {
      // Silently fail cache operations to not break main functionality
    }
  }

  /// Clear all cached data
  void clearCache() {
    _cachedDevotionals = null;
    _lastCacheTime = null;
    
    // Also clear local data source cache if available
    if (localDataSource is DevotionalLocalDataSourceImpl) {
      (localDataSource as DevotionalLocalDataSourceImpl).clearCache();
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'hasCachedData': _cachedDevotionals != null,
      'cachedCount': _cachedDevotionals?.length ?? 0,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
      'isCacheValid': _isCacheValid(),
    };
  }
}