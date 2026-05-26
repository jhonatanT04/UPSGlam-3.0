import 'package:flutter/material.dart';
import '../../../core/models/post.dart';
import '../../../core/theme/app_theme.dart';
import '../../comments/comments_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;

  const PostCard({super.key, required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post),
          _PostImage(imageUrl: post.imageUrl),
          _Actions(post: post, onLike: onLike),
          _LikesRow(post: post),
          if (post.caption != null && post.caption!.isNotEmpty)
            _Caption(username: post.username, caption: post.caption!),
          _CommentsHint(post: post),
          const SizedBox(height: 4),
          const Divider(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Post post;
  const _Header({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar con borde dorado UPS
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.upsGradient,
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.white,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppTheme.background,
                backgroundImage: post.avatarUrl != null
                    ? NetworkImage(post.avatarUrl!)
                    : null,
                child: post.avatarUrl == null
                    ? Text(
                        post.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                Text(
                  _timeAgo(post.createdAt),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_horiz, color: AppTheme.textPrimary),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}

class _PostImage extends StatelessWidget {
  final String imageUrl;
  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                color: AppTheme.background,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.navy,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
        errorBuilder: (context, e, s) => Container(
          color: AppTheme.background,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined,
                  size: 48, color: AppTheme.textSecondary),
              SizedBox(height: 8),
              Text('Sin imagen',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  const _Actions({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          // Like con animación de escala
          _LikeButton(isLiked: post.isLiked, onTap: onLike),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CommentsScreen(postId: post.id)),
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 24),
            color: AppTheme.textPrimary,
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined, size: 24),
            color: AppTheme.textPrimary,
            padding: const EdgeInsets.all(8),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border, size: 24),
            color: AppTheme.textPrimary,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  const _LikeButton({required this.isLiked, required this.onTap});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 1.35).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _tap() {
    widget.onTap();
    _ctrl.forward().then((_) => _ctrl.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        onPressed: _tap,
        icon: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? AppTheme.like : AppTheme.textPrimary,
          size: 26,
        ),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

class _LikesRow extends StatelessWidget {
  final Post post;
  const _LikesRow({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Text(
        '${post.likesCount} Me gusta',
        style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String username;
  final String caption;
  const _Caption({required this.username, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              color: AppTheme.textPrimary, fontSize: 13.5, height: 1.3),
          children: [
            TextSpan(
                text: '$username ',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: caption),
          ],
        ),
      ),
    );
  }
}

class _CommentsHint extends StatelessWidget {
  final Post post;
  const _CommentsHint({required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.commentsCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 3, 14, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CommentsScreen(postId: post.id)),
        ),
        child: Text(
          'Ver los ${post.commentsCount} comentarios',
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
