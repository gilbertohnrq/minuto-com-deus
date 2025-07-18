import 'notification_settings.dart';

/// Local user entity for freemium model without authentication
class LocalUser {
  final String id; // Generated locally
  final String? name;
  final bool isPremium;
  final NotificationSettings notificationSettings;
  final DateTime createdAt;
  final DateTime? premiumExpirationDate;
  
  const LocalUser({
    required this.id,
    this.name,
    required this.isPremium,
    required this.notificationSettings,
    required this.createdAt,
    this.premiumExpirationDate,
  });
  
  LocalUser copyWith({
    String? id,
    String? name,
    bool? isPremium,
    NotificationSettings? notificationSettings,
    DateTime? createdAt,
    DateTime? premiumExpirationDate,
  }) {
    return LocalUser(
      id: id ?? this.id,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt ?? this.createdAt,
      premiumExpirationDate: premiumExpirationDate ?? this.premiumExpirationDate,
    );
  }

  /// Check if premium subscription is still active
  bool get isActivePremium {
    if (!isPremium) return false;
    if (premiumExpirationDate == null) return true; // Lifetime premium
    return DateTime.now().isBefore(premiumExpirationDate!);
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalUser &&
        other.id == id &&
        other.name == name &&
        other.isPremium == isPremium &&
        other.notificationSettings == notificationSettings &&
        other.createdAt == createdAt &&
        other.premiumExpirationDate == premiumExpirationDate;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      isPremium,
      notificationSettings,
      createdAt,
      premiumExpirationDate,
    );
  }
  
  @override
  String toString() {
    return 'LocalUser(id: $id, name: $name, isPremium: $isPremium, isActivePremium: $isActivePremium)';
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPremium': isPremium,
      'notificationSettings': notificationSettings.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'premiumExpirationDate': premiumExpirationDate?.toIso8601String(),
    };
  }

  /// Create from JSON for local storage
  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      id: json['id'],
      name: json['name'],
      isPremium: json['isPremium'] ?? false,
      notificationSettings: NotificationSettings.fromMap(json['notificationSettings']),
      createdAt: DateTime.parse(json['createdAt']),
      premiumExpirationDate: json['premiumExpirationDate'] != null 
          ? DateTime.parse(json['premiumExpirationDate']) 
          : null,
    );
  }
}
