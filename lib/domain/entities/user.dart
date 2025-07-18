import 'notification_settings.dart';

class User {
  final String id;
  final String email;
  final String? name;
  final bool isPremium;
  final NotificationSettings notificationSettings;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.email,
    this.name,
    required this.isPremium,
    required this.notificationSettings,
    required this.createdAt,
  });
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.isPremium == isPremium &&
        other.notificationSettings == notificationSettings &&
        other.createdAt == createdAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        isPremium.hashCode ^
        notificationSettings.hashCode ^
        createdAt.hashCode;
  }
  
  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, isPremium: $isPremium, notificationSettings: $notificationSettings, createdAt: $createdAt)';
  }
}