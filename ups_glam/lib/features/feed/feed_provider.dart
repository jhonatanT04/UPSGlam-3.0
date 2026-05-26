import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/post.dart';
import '../../core/services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

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
    final updated = post.copyWith(
      isLiked: !post.isLiked,
      likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    state = AsyncData([...posts]..[idx] = updated);
    await ref.read(apiServiceProvider).toggleLike(postId);
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
