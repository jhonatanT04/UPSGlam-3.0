import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_result.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isLoading;
  final String? accessToken;
  final String? userId;
  final String? email;
  final String? username;

  const AuthState({
    this.isLoading = false,
    this.accessToken,
    this.userId,
    this.email,
    this.username,
  });

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  AuthState copyWith({
    bool? isLoading,
    String? accessToken,
    String? userId,
    String? email,
    String? username,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        accessToken: accessToken ?? this.accessToken,
        userId: userId ?? this.userId,
        email: email ?? this.email,
        username: username ?? this.username,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    state = token != null && token.isNotEmpty
        ? AuthState(
            accessToken: token,
            userId: prefs.getString('user_id'),
            email: prefs.getString('email'),
            username: prefs.getString('username'),
          )
        : const AuthState();
  }

  Future<void> login(String identifier, String password) async {
    final result = await ApiService().login(identifier, password);
    await _persist(result);
    state = AuthState(
      accessToken: result.accessToken,
      userId: result.userId,
      email: result.email,
      username: result.username,
    );
  }

  Future<void> register(String email, String password) async {
    final result = await ApiService().register(email, password);
    await _persist(result);
    state = AuthState(
      accessToken: result.accessToken,
      userId: result.userId,
      email: result.email,
      username: result.username,
    );
  }

  Future<void> updateProfile({String? username}) async {
    final api = ApiService()..authToken = state.accessToken;
    await api.updateProfile(username: username);
    if (username != null) {
      state = state.copyWith(username: username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
    }
  }

  Future<void> logout() async {
    if (state.accessToken != null) {
      try {
        final api = ApiService()..authToken = state.accessToken;
        await api.logout();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AuthState();
  }

  Future<void> _persist(AuthResult r) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', r.accessToken);
    await prefs.setString('user_id', r.userId);
    await prefs.setString('email', r.email);
    await prefs.setString('username', r.username);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// Singleton API service that carries the current auth token.
final apiServiceProvider = Provider<ApiService>((ref) {
  final token = ref.watch(authProvider.select((s) => s.accessToken));
  final api = ApiService();
  api.authToken = token;
  return api;
});
