import '../../domain/entities/devotional.dart';

class DevotionalModel {
  final String data;
  final String versiculo;
  final String mensagem;

  const DevotionalModel({
    required this.data,
    required this.versiculo,
    required this.mensagem,
  });

  factory DevotionalModel.fromJson(Map<String, dynamic> json) {
    return DevotionalModel(
      data: json['data'] as String,
      versiculo: json['versiculo'] as String,
      mensagem: json['mensagem'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'versiculo': versiculo,
      'mensagem': mensagem,
    };
  }

  Devotional toEntity() {
    return Devotional(
      id: data,
      date: DateTime.parse(data),
      verse: versiculo,
      message: mensagem,
    );
  }
}