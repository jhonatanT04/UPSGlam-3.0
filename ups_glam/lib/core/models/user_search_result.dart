class UserSearchResult {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isFollowing;

  const UserSearchResult({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.isFollowing,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> j) => UserSearchResult(
        id: j['id'] as String,
        username: j['username'] as String,
        avatarUrl: j['avatar_url'] as String?,
        isFollowing: j['is_following'] as bool? ?? false,
      );

  UserSearchResult copyWith({bool? isFollowing}) => UserSearchResult(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
        isFollowing: isFollowing ?? this.isFollowing,
      );
}
