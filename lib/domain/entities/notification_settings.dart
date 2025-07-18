import 'package:flutter/material.dart';

class NotificationSettings {
  final bool enabled;
  final TimeOfDay scheduledTime;
  final List<int> selectedDays; // 1-7 for Monday-Sunday
  
  const NotificationSettings({
    required this.enabled,
    required this.scheduledTime,
    required this.selectedDays,
  });
  
  /// Default notification settings (enabled at 8:00 AM, all days)
  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings(
      enabled: true,
      scheduledTime: TimeOfDay(hour: 8, minute: 0),
      selectedDays: [1, 2, 3, 4, 5, 6, 7], // All days of the week
    );
  }
  
  /// Create from map (for JSON/Firestore serialization)
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] ?? true,
      scheduledTime: TimeOfDay(
        hour: map['scheduledHour'] ?? 8,
        minute: map['scheduledMinute'] ?? 0,
      ),
      selectedDays: List<int>.from(map['selectedDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
    );
  }
  
  /// Convert to map (for JSON/Firestore serialization)
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'scheduledHour': scheduledTime.hour,
      'scheduledMinute': scheduledTime.minute,
      'selectedDays': selectedDays,
    };
  }
  
  /// Copy with new values
  NotificationSettings copyWith({
    bool? enabled,
    TimeOfDay? scheduledTime,
    List<int>? selectedDays,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is NotificationSettings &&
      other.enabled == enabled &&
      other.scheduledTime == scheduledTime &&
      other.selectedDays.length == selectedDays.length &&
      other.selectedDays.every((day) => selectedDays.contains(day));
  }
  
  @override
  int get hashCode {
    return enabled.hashCode ^
      scheduledTime.hashCode ^
      selectedDays.hashCode;
  }
  
  @override
  String toString() {
    return 'NotificationSettings(enabled: $enabled, scheduledTime: $scheduledTime, selectedDays: $selectedDays)';
  }
}