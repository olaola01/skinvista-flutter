import '../core/api_client/api_client.dart';
import '../models/game_score.dart';

class GameScoreRepository {
  final ApiClient apiClient;

  GameScoreRepository({required this.apiClient});

  Future<void> saveGameScore({
    required int score,
  }) async {
    try {
      await apiClient.postJson(
        endpoint: '/save-score',
        body: {
          'score': score,
        },
      );
    } catch (e) {
      throw Exception('Failed to save game score: $e');
    }
  }

  Future<List<GameScore>> getLeaderboard() async {
    try {
      final response = await apiClient.getJson(endpoint: '/leaderboard');
      final List<dynamic> data = response['data'];
      return data.map((json) => GameScore.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }
}