class Devotional {
  final String id;
  final DateTime date;
  final String verse;
  final String message;
  final String? imageUrl;
  
  const Devotional({
    required this.id,
    required this.date,
    required this.verse,
    required this.message,
    this.imageUrl,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Devotional &&
        other.id == id &&
        other.date == date &&
        other.verse == verse &&
        other.message == message &&
        other.imageUrl == imageUrl;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        verse.hashCode ^
        message.hashCode ^
        imageUrl.hashCode;
  }
  
  @override
  String toString() {
    return 'Devotional(id: $id, date: $date, verse: $verse, message: $message, imageUrl: $imageUrl)';
  }
}