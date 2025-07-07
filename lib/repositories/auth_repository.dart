import '../core/api_client/api_client.dart';
import '../responses/token_response.dart';


class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<TokenResponse> getToken({
    required String email,
    List<String>? scopes,
  }) async {
    try {
      final response = await apiClient.postJson(
        endpoint: '/get/token',
        body: {
          'email': email,
          if (scopes != null) 'scopes': scopes,
        },
      );
      return TokenResponse.fromJson(response);
    } catch (e) {
      if (e is ApiException) {
        throw Exception(e.message); // Pass the backend message
      }
      throw Exception('Failed to authenticate: $e');
    }
  }
}