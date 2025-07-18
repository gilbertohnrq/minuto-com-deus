/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(String message) : super(message, 'network_error');
}

/// Exception thrown when authentication operations fail
class AuthException extends AppException {
  const AuthException(super.message, super.code);
}

/// Exception thrown when a devotional is not found for a specific date
class DevotionalNotFoundException extends AppException {
  const DevotionalNotFoundException(String date) 
    : super('Devocional não encontrado para a data: $date', 'devotional_not_found');
}

/// Exception thrown when devotional data operations fail
class DevotionalDataException extends AppException {
  const DevotionalDataException(String message) : super(message, 'devotional_data_error');
}

/// Exception thrown when user data operations fail
class UserDataException extends AppException {
  const UserDataException(String message) : super(message, 'user_data_error');
}

/// Exception thrown when notification operations fail
class NotificationException extends AppException {
  const NotificationException(String message) : super(message, 'notification_error');
}

/// Exception thrown when ad operations fail
class AdException extends AppException {
  const AdException(String message) : super(message, 'ad_error');
}

/// Exception thrown when local storage operations fail
class StorageException extends AppException {
  const StorageException(String message) : super(message, 'storage_error');
}

/// Exception thrown when JSON parsing fails
class ParseException extends AppException {
  const ParseException(String message) : super(message, 'parse_error');
}

/// Exception thrown when data source operations fail
class DataSourceException extends AppException {
  const DataSourceException(String message) : super(message, 'data_source_error');
}