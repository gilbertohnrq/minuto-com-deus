class Reflection {
  final String id;
  final String devotionalId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reflection({
    required this.id,
    required this.devotionalId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  Reflection copyWith({
    String? id,
    String? devotionalId,
    String? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reflection(
      id: id ?? this.id,
      devotionalId: devotionalId ?? this.devotionalId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reflection &&
        other.id == id &&
        other.devotionalId == devotionalId &&
        other.userId == userId &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        devotionalId.hashCode ^
        userId.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Reflection(id: $id, devotionalId: $devotionalId, userId: $userId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}