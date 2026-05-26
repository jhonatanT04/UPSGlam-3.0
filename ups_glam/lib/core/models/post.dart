class Post {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String imageUrl;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.imageUrl,
    this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
  });

  Post copyWith({int? likesCount, bool? isLiked}) => Post(
        id: id,
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        imageUrl: imageUrl,
        caption: caption,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount,
        isLiked: isLiked ?? this.isLiked,
        createdAt: createdAt,
      );

  factory Post.fromPerfilJson(Map<String, dynamic> j) => Post(
        id: j['id'].toString(),
        userId: j['usuario_id'] as String? ?? '',
        username: j['username'] as String? ?? '',
        avatarUrl: j['avatar_url'] as String?,
        imageUrl: j['imagen_url'] as String? ?? '',
        caption: j['descripcion'] as String?,
        likesCount: (j['likes_count'] as num?)?.toInt() ?? 0,
        commentsCount: (j['comentarios_count'] as num?)?.toInt() ?? 0,
        isLiked: j['is_liked'] as bool? ?? false,
        createdAt: j['creado_en'] != null
            ? DateTime.parse(j['creado_en'] as String)
            : DateTime.now(),
      );

  factory Post.fromJson(Map<String, dynamic> j) => Post(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        username: j['username'] as String,
        avatarUrl: j['avatar_url'] as String?,
        imageUrl: j['image_url'] as String,
        caption: j['caption'] as String?,
        likesCount: (j['likes_count'] as num).toInt(),
        commentsCount: (j['comments_count'] as num).toInt(),
        isLiked: j['is_liked'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'image_url': imageUrl,
        'caption': caption,
      };
}
