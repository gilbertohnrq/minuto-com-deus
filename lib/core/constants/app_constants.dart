class AppConstants {
  // App Information
  static const String appName = 'Devocional Diário';
  static const String appVersion = '1.0.0';
  
  // Notification Constants
  static const String notificationChannelId = 'devotional_notifications';
  static const String notificationChannelName = 'Daily Devotionals';
  static const String notificationChannelDescription = 'Notifications for daily devotional messages';
  
  // Default notification settings
  static const int defaultNotificationHour = 8;
  static const int defaultNotificationMinute = 0;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String devotionalsCollection = 'devotionals';
  
  // Local Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String notificationPrefsKey = 'notification_preferences';
  
  // Error Messages
  static const String genericErrorMessage = 'Algo deu errado. Tente novamente.';
  static const String networkErrorMessage = 'Verifique sua conexão com a internet.';
  static const String authErrorMessage = 'Erro de autenticação. Verifique suas credenciais.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login realizado com sucesso!';
  static const String registrationSuccessMessage = 'Conta criada com sucesso!';
  
  // Devotional Messages
  static const String noDevotionalMessage = 'Em breve teremos um devocional para este dia';
  static const String loadingDevotionalMessage = 'Carregando devocional...';
}