import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/comment.dart';
import '../../core/theme/app_theme.dart';
import '../feed/feed_provider.dart';

final _commentsProvider = FutureProvider.autoDispose
    .family<List<Comment>, String>((ref, postId) =>
        ref.read(apiServiceProvider).getComments(postId));

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  final List<Comment> _optimistic = [];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _ctrl.clear();
    try {
      final comment = await ref
          .read(apiServiceProvider)
          .addComment(widget.postId, text);
      setState(() => _optimistic.add(comment));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(_commentsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.upsGradient)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Error al cargar comentarios',
                      style:
                          TextStyle(color: AppTheme.textSecondary))),
              data: (serverComments) {
                final all = [...serverComments, ..._optimistic];
                if (all.isEmpty) {
                  return const Center(
                    child: Text('Sin comentarios aún. ¡Sé el primero!',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: all.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 4),
                  itemBuilder: (_, i) => _CommentTile(comment: all[i]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          _CommentInput(
              ctrl: _ctrl, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
            child: Text(
              comment.username[0].toUpperCase(),
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                          text: '${comment.username} ',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      TextSpan(text: comment.content),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(comment.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;

  const _CommentInput(
      {required this.ctrl, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  hintText: 'Añade un comentario...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: sending ? null : onSend,
              icon: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
