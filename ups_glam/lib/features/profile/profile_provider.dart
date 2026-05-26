import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/post.dart';
import '../../core/providers/auth_provider.dart';

final profilePostsProvider =
    FutureProvider.autoDispose<List<Post>>((ref) {
  final userId = ref.watch(authProvider.select((s) => s.userId)) ?? '';
  return ref.read(apiServiceProvider).getUserPosts(userId);
});
