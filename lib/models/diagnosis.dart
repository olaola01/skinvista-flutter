class Diagnosis {
  final int id;
  final String condition;
  final double confidence;
  final String userId;
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
      id: json['id'] as int,
      condition: json['condition'] as String,
      confidence: json['confidence'] is num
          ? (json['confidence'] as num).toDouble().clamp(0.0, 100.0)
          : (double.tryParse(json['confidence'].toString()) ?? 0.0).clamp(0.0, 100.0), // Handle String case
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imagePath: json['image_path'] as String?,
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