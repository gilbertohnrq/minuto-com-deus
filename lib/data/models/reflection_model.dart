import '../../domain/entities/reflection.dart';

class ReflectionModel extends Reflection {
  const ReflectionModel({
    required super.id,
    required super.devotionalId,
    required super.userId,
    required super.content,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String,
      devotionalId: json['devotionalId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'devotionalId': devotionalId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ReflectionModel.fromEntity(Reflection reflection) {
    return ReflectionModel(
      id: reflection.id,
      devotionalId: reflection.devotionalId,
      userId: reflection.userId,
      content: reflection.content,
      createdAt: reflection.createdAt,
      updatedAt: reflection.updatedAt,
    );
  }

  Reflection toEntity() {
    return Reflection(
      id: id,
      devotionalId: devotionalId,
      userId: userId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}