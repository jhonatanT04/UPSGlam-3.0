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
        id: j['id']?.toString() ?? '',
        postId: j['publicacion_id']?.toString() ?? '',
        userId: j['usuario_id'] as String? ?? '',
        username: j['username'] as String? ?? '',
        avatarUrl: j['avatar_url'] as String?,
        content: j['texto'] as String? ?? '',
        createdAt: j['creado_en'] != null
            ? DateTime.parse(j['creado_en'] as String)
            : DateTime.now(),
      );
}
