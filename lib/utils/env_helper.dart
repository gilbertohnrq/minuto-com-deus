import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvHelper {
  /// Get environment variable from dotenv first, then fall back to system environment
  /// This allows local development with .env files and CI builds with system env vars
  static String? getEnv(String key) {
    // First try to get from dotenv (local development)
    String? value = dotenv.env[key];
    
    // If not found in dotenv, try system environment (CI builds)
    if (value == null || value.isEmpty) {
      value = Platform.environment[key];
    }
    
    return value;
  }
  
  /// Get environment variable with a default value
  static String getEnvOrDefault(String key, String defaultValue) {
    return getEnv(key) ?? defaultValue;
  }
  
  /// Check if running in CI environment
  static bool get isCI => Platform.environment['CI'] == 'true';
}