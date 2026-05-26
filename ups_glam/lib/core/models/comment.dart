class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'] as String,
        postId: j['post_id'] as String,
        userId: j['user_id'] as String,
        username: j['username'] as String,
        avatarUrl: j['avatar_url'] as String?,
        content: j['content'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
