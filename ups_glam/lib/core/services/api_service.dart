import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/gpu_process_result.dart';
import '../models/user_profile.dart';
import '../models/user_search_result.dart';

class ApiService {
  final String baseUrl;
  String? authToken;

  ApiService({this.baseUrl = 'http://localhost:8080'});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // ── Auth ──────────────────────────────────────────────
  Future<AuthResult> login(String identifier, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    return AuthResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<AuthResult> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 201) throw Exception(_extractError(res.body));
    return AuthResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String identifier) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/forgot-password'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(_extractError(res.body));
    }
  }

  Future<void> logout() async {
    if (authToken == null) return;
    await http.post(
      Uri.parse('$baseUrl/api/v1/auth/logout'),
      headers: headers,
    );
  }

  // ── Procesamiento GPU ─────────────────────────────────
  Future<GpuProcessResult> processImage(
    File imageFile, {
    required String filterName,
    int filterSize = 65,
  }) async {
    final uri = Uri.parse(
        '$baseUrl/api/v1/images/process/$filterName?filter_size=$filterSize');
    final request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    if (authToken != null) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception('Error al procesar imagen: ${streamed.statusCode}\n$body');
    }
    return GpuProcessResult.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  // ── Feed ─────────────────────────────────────────────
  Future<List<Post>> getFeed() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/feed'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Post.fromPerfilJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Likes ─────────────────────────────────────────────
  Future<void> toggleLike(String postId, {required bool currentlyLiked}) async {
    if (currentlyLiked) {
      await http.delete(
        Uri.parse('$baseUrl/api/v1/publicaciones/$postId/like'),
        headers: headers,
      );
    } else {
      await http.post(
        Uri.parse('$baseUrl/api/v1/publicaciones/$postId/like'),
        headers: headers,
      );
    }
  }

  // ── Comments ──────────────────────────────────────────
  Future<List<Comment>> getComments(String postId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/publicaciones/$postId/comentarios'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Comment> addComment(String postId, String content) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/publicaciones/$postId/comentarios'),
      headers: headers,
      body: jsonEncode({'texto': content}),
    );
    if (res.statusCode != 201) throw Exception(_extractError(res.body));
    return Comment.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Posts ─────────────────────────────────────────────
  Future<Post> createPost({
    required String imageUrl,
    String? caption,
  }) async {
    final body = <String, dynamic>{'imagen_url': imageUrl};
    if (caption != null && caption.isNotEmpty) body['descripcion'] = caption;

    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/publicaciones'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) throw Exception(_extractError(res.body));
    return Post.fromPerfilJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // ── Perfil ────────────────────────────────────────────
  Future<UserProfile> getMyProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/perfil/me'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    return UserProfile.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateProfile({String? username}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/v1/perfil/me'),
      headers: headers,
      body: jsonEncode({'username': username}),
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Búsqueda y follows ────────────────────────────────
  Future<List<UserSearchResult>> searchUsers(String query) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/perfil/search?q=${Uri.encodeComponent(query)}'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> followUser(String userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/follow/$userId'),
      headers: headers,
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(_extractError(res.body));
    }
  }

  Future<void> unfollowUser(String userId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/v1/follow/$userId'),
      headers: headers,
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception(_extractError(res.body));
    }
  }

  // ── Helpers ───────────────────────────────────────────
  String _extractError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] as String? ??
          json['msg'] as String? ??
          json['error'] as String? ??
          'Error desconocido';
    } catch (_) {
      return body.isNotEmpty ? body : 'Error desconocido';
    }
  }
}

