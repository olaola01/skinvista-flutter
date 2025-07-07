class Diagnosis {
  final int id;
  final String condition;
  final double confidence;
  final int userId;
  final String? imagePath;
  final DateTime createdAt;

  Diagnosis({
    required this.id,
    required this.condition,
    required this.confidence,
    required this.userId,
    this.imagePath,
    required this.createdAt,

  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'],
      condition: json['condition'],
      confidence: (json['confidence'] as num).toDouble(),
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'confidence': confidence,
      'image_path': imagePath,
      'user_id': userId,
    };
  }
}