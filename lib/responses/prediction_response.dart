class PredictionResponse {
  final String condition;
  final double confidence;

  PredictionResponse({
    required this.condition,
    required this.confidence,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      condition: json['condition'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'confidence': confidence,
    };
  }
}