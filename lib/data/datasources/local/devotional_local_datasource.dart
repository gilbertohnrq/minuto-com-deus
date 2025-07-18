import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/devotional_model.dart';
import '../../../core/errors/exceptions.dart';

abstract class DevotionalLocalDataSource {
  Future<List<DevotionalModel>> loadDevotionals();
  Future<DevotionalModel?> getDevotionalByDate(String date);
}

class DevotionalLocalDataSourceImpl implements DevotionalLocalDataSource {
  static const String _assetPath = 'assets/data/devocionais.json';
  List<DevotionalModel>? _cachedDevotionals;

  @override
  Future<List<DevotionalModel>> loadDevotionals() async {
    if (_cachedDevotionals != null) {
      return _cachedDevotionals!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _cachedDevotionals = jsonList
          .map((json) => DevotionalModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return _cachedDevotionals!;
    } catch (e) {
      throw DataSourceException('Failed to load devotionals from assets: $e');
    }
  }

  @override
  Future<DevotionalModel?> getDevotionalByDate(String date) async {
    try {
      final devotionals = await loadDevotionals();
      
      for (final devotional in devotionals) {
        if (devotional.data == date) {
          return devotional;
        }
      }
      
      return null;
    } catch (e) {
      throw DataSourceException('Failed to get devotional by date: $e');
    }
  }

  /// Clear cached data (useful for testing or memory management)
  void clearCache() {
    _cachedDevotionals = null;
  }
}