import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_search_result.dart';
import '../../core/providers/auth_provider.dart';

class SearchState {
  final List<UserSearchResult> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    List<UserSearchResult>? results,
    bool? isLoading,
    String? error,
  }) =>
      SearchState(
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _ref.read(apiServiceProvider).searchUsers(query);
      state = SearchState(results: results);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> toggleFollow(String userId) async {
    final idx = state.results.indexWhere((r) => r.id == userId);
    if (idx < 0) return;

    final user = state.results[idx];
    final newFollowing = !user.isFollowing;

    // Actualización optimista
    final updated = List<UserSearchResult>.from(state.results);
    updated[idx] = user.copyWith(isFollowing: newFollowing);
    state = state.copyWith(results: updated);

    try {
      final api = _ref.read(apiServiceProvider);
      if (newFollowing) {
        await api.followUser(userId);
      } else {
        await api.unfollowUser(userId);
      }
    } catch (_) {
      // Revertir si falla
      final reverted = List<UserSearchResult>.from(state.results);
      reverted[idx] = user;
      state = state.copyWith(results: reverted);
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
        (ref) => SearchNotifier(ref));
