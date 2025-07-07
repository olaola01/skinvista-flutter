class GameScore {
  final int score;
  final String userEmail;
  final DateTime createdAt;

  GameScore({
    required this.score,
    required this.userEmail,
    required this.createdAt,
  });

  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      score: json['score'],
      userEmail: json['user_email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}