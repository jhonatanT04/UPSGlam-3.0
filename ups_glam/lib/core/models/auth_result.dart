class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String username;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.username,
  });

  factory AuthResult.fromJson(Map<String, dynamic> j) {
    final user = j['user'] as Map<String, dynamic>? ?? {};
    final meta = user['user_metadata'] as Map<String, dynamic>? ?? {};
    return AuthResult(
      accessToken: j['access_token'] as String? ?? '',
      refreshToken: j['refresh_token'] as String? ?? '',
      userId: user['id']?.toString() ?? '',
      email: user['email'] as String? ?? '',
      username: meta['username'] as String? ?? '',
    );
  }
}
