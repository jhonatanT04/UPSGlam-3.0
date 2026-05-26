import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_profile.dart';
import '../../core/providers/auth_provider.dart';

final myProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  ref.watch(authProvider.select((s) => s.userId));
  return ref.read(apiServiceProvider).getMyProfile();
});
