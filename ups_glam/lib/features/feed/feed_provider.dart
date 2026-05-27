import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/post.dart';
import '../../core/providers/auth_provider.dart';

export '../../core/providers/auth_provider.dart' show apiServiceProvider;

final feedProvider =
    AsyncNotifierProvider<FeedNotifier, List<Post>>(FeedNotifier.new);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() =>
      ref.read(apiServiceProvider).getFeed();

  Future<void> toggleLike(String postId) async {
    final posts = state.valueOrNull ?? [];
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = posts[idx];
    // Actualización optimista
    state = AsyncData([...posts]
      ..[idx] = post.copyWith(
        isLiked: !post.isLiked,
        likesCount:
            post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
      ));

    try {
      await ref
          .read(apiServiceProvider)
          .toggleLike(postId, currentlyLiked: post.isLiked);
    } catch (_) {
      // Revertir si el API falla
      final current = state.valueOrNull ?? [];
      final revertIdx = current.indexWhere((p) => p.id == postId);
      if (revertIdx >= 0) {
        state = AsyncData([...current]..[revertIdx] = post);
      }
    }
  }

  Future<void> addNewPost(Post post) async {
    final posts = state.valueOrNull ?? [];
    state = AsyncData([post, ...posts]);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(apiServiceProvider).getFeed());
  }
}
