import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'feed_provider.dart';
import 'widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: const Text(
          'UPSGlam',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppTheme.navy,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined, color: AppTheme.navy),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 52, color: AppTheme.textSecondary),
              const SizedBox(height: 10),
              const Text('Sin conexión al servidor',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              const Text('El feed se cargará cuando el backend esté activo',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.read(feedProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (posts) => RefreshIndicator(
          color: AppTheme.navy,
          onRefresh: () => ref.read(feedProvider.notifier).refresh(),
          child: posts.isEmpty
              ? const Center(
                  child: Text('Aún no hay publicaciones.',
                      style: TextStyle(color: AppTheme.textSecondary)),
                )
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (_, i) => PostCard(
                    post: posts[i],
                    onLike: () => ref
                        .read(feedProvider.notifier)
                        .toggleLike(posts[i].id),
                  ),
                ),
        ),
      ),
    );
  }
}
