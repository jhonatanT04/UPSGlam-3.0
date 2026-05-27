import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/post.dart';
import '../../core/models/user_profile.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../comments/comments_screen.dart';
import '../feed/feed_provider.dart';
import '../home/home_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);
    final username = ref.watch(authProvider.select((s) => s.username)) ?? '';

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          username.isNotEmpty ? username : 'Perfil',
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppTheme.textPrimary),
            onPressed: () => ref.read(homeTabProvider.notifier).state = 2,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
            onSelected: (value) {
              if (value == 'logout') _logout(context, ref);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cerrar sesión',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              const Text('Error al cargar perfil',
                  style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(myProfileProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _ProfileHeader(profile: profile),
        ),
        SliverToBoxAdapter(
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
        const SliverToBoxAdapter(child: _GridTabBar()),
        if (profile.publicaciones.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 52, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('Sin publicaciones aún',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    SizedBox(height: 6),
                    Text('Sube tu primera imagen con filtro GPU',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _GridTile(
                post: profile.publicaciones[i],
                onTap: () =>
                    _showPostDetail(context, profile.publicaciones[i]),
              ),
              childCount: profile.publicaciones.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
            ),
          ),
      ],
    );
  }

  void _showPostDetail(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostDetailSheet(post: post),
    );
  }
}

// ── Header ────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.upsGradient,
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppTheme.background,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.username.isNotEmpty
                              ? profile.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navy,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCol(
                        value: profile.publicacionesCount, label: 'Posts'),
                    _StatCol(
                        value: profile.seguidores, label: 'Seguidores'),
                    _StatCol(
                        value: profile.seguidos, label: 'Siguiendo'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(profile.username,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditProfileScreen()),
              );
              ref.invalidate(myProfileProvider);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 34),
              side: const BorderSide(color: AppTheme.inputBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              foregroundColor: AppTheme.textPrimary,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            child: const Text('Editar perfil'),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final int value;
  final String label;
  const _StatCol({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Tab bar ───────────────────────────────────────────
class _GridTabBar extends StatelessWidget {
  const _GridTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppTheme.navy, width: 1.5)),
              ),
              child:
                  const Icon(Icons.grid_on, color: AppTheme.navy, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid tile ─────────────────────────────────────────
class _GridTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  const _GridTile({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(color: AppTheme.background),
            errorBuilder: (context2, err, st) => Container(
              color: AppTheme.background,
              child: const Icon(Icons.image_outlined,
                  color: AppTheme.textSecondary),
            ),
          ),
          if (post.isLiked)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.favorite,
                    color: AppTheme.like, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Detalle del post (bottom sheet) ──────────────────
class _PostDetailSheet extends ConsumerStatefulWidget {
  final Post post;
  const _PostDetailSheet({required this.post});

  @override
  ConsumerState<_PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends ConsumerState<_PostDetailSheet> {
  late bool _isLiked;
  late int _likesCount;
  bool _liking = false;

  @override
  void initState() {
    super.initState();
    final feedPosts = ref.read(feedProvider).valueOrNull ?? [];
    final feedPost = feedPosts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    _isLiked = feedPost.isLiked;
    _likesCount = feedPost.likesCount;
  }

  Future<void> _toggleLike() async {
    if (_liking) return;
    final wasLiked = _isLiked;
    setState(() {
      _liking = true;
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    try {
      await ref.read(feedProvider.notifier).toggleLike(widget.post.id);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likesCount += wasLiked ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                  color: AppTheme.inputBorder,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.upsGradient,
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.background,
                            backgroundImage: post.avatarUrl != null
                                ? NetworkImage(post.avatarUrl!)
                                : null,
                            child: post.avatarUrl == null
                                ? Text(
                                    post.username.isNotEmpty
                                        ? post.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: AppTheme.navy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(post.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5)),
                      ],
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(post.imageUrl, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleLike,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(_isLiked),
                              color: _isLiked
                                  ? AppTheme.like
                                  : AppTheme.textPrimary,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('$_likesCount',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      CommentsScreen(postId: post.id)),
                            );
                          },
                          child: const Icon(Icons.chat_bubble_outline,
                              size: 24, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Text('${post.commentsCount}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  if (post.caption != null && post.caption!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13.5,
                              height: 1.3),
                          children: [
                            TextSpan(
                                text: '${post.username} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            TextSpan(text: post.caption),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
