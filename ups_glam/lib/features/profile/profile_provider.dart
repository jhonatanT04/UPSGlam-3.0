import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/post.dart';
import '../feed/feed_provider.dart';

// En el futuro este ID vendrá de Supabase Auth
const currentUserId = 'user1';
const currentUsername = 'maria_ups';

final profilePostsProvider =
    FutureProvider.autoDispose<List<Post>>((ref) =>
        ref.read(apiServiceProvider).getUserPosts(currentUserId));
