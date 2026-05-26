import 'post.dart';

class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final int publicacionesCount;
  final int totalLikes;
  final int seguidores;
  final int seguidos;
  final List<Post> publicaciones;

  const UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.publicacionesCount,
    required this.totalLikes,
    required this.seguidores,
    required this.seguidos,
    required this.publicaciones,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    final pubs = (j['publicaciones'] as List<dynamic>? ?? [])
        .map((e) => Post.fromPerfilJson(e as Map<String, dynamic>))
        .toList();
    return UserProfile(
      id: j['id'] as String,
      username: j['username'] as String,
      avatarUrl: j['avatar_url'] as String?,
      publicacionesCount: (j['publicaciones_count'] as num? ?? 0).toInt(),
      totalLikes: (j['total_likes'] as num? ?? 0).toInt(),
      seguidores: (j['seguidores'] as num? ?? 0).toInt(),
      seguidos: (j['seguidos'] as num? ?? 0).toInt(),
      publicaciones: pubs,
    );
  }
}
