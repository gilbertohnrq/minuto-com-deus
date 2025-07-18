import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/notification_settings.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final bool isPremium;
  final Map<String, dynamic> notificationSettings;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  
  const UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.isPremium,
    required this.notificationSettings,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception('Document data is null for user: ${doc.id}');
    }
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      isPremium: data['isPremium'] ?? false,
      notificationSettings: Map<String, dynamic>.from(
        data['notificationSettings'] ?? NotificationSettings.defaultSettings().toMap(),
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
    );
  }
  
  /// Create UserModel from domain User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      isPremium: user.isPremium,
      notificationSettings: user.notificationSettings.toMap(),
      createdAt: Timestamp.fromDate(user.createdAt),
      updatedAt: Timestamp.now(),
    );
  }
  
  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'isPremium': isPremium,
      'notificationSettings': notificationSettings,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? Timestamp.now(),
    };
  }
  
  /// Convert to domain User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      isPremium: isPremium,
      notificationSettings: NotificationSettings.fromMap(notificationSettings),
      createdAt: createdAt.toDate(),
    );
  }
  
  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    Map<String, dynamic>? notificationSettings,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.isPremium == isPremium &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        isPremium.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, isPremium: $isPremium, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}