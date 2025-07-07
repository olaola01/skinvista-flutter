class TokenResponse {
  final String token;

  TokenResponse({required this.token});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['data']['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}