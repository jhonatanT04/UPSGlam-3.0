import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/gpu_process_result.dart';

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
    // TODO: GET $baseUrl/api/v1/feed
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockPosts();
  }

  // ── Likes ─────────────────────────────────────────────
  Future<void> toggleLike(String postId) async {
    // TODO: POST $baseUrl/api/v1/publicaciones/$postId/like
    await Future.delayed(const Duration(milliseconds: 150));
  }

  // ── Comments ──────────────────────────────────────────
  Future<List<Comment>> getComments(String postId) async {
    // TODO: GET $baseUrl/api/v1/publicaciones/$postId/comentarios
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockComments(postId);
  }

  Future<Comment> addComment(String postId, String content) async {
    // TODO: POST $baseUrl/api/v1/publicaciones/$postId/comentarios
    await Future.delayed(const Duration(milliseconds: 300));
    return Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      userId: 'me',
      username: 'yo',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  // ── Posts ─────────────────────────────────────────────
  Future<Post> createPost({
    required String imageUrl,
    String? caption,
  }) async {
    // TODO: POST $baseUrl/api/v1/publicaciones
    await Future.delayed(const Duration(milliseconds: 400));
    return Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'me',
      username: 'yo',
      imageUrl: imageUrl,
      caption: caption,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );
  }

  // ── Perfil ────────────────────────────────────────────
  Future<Map<String, dynamic>> updateProfile({String? username}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/v1/perfil/me'),
      headers: headers,
      body: jsonEncode({
        'username': username,
      }),
    );
    if (res.statusCode != 200) throw Exception(_extractError(res.body));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Post>> getUserPosts(String userId) async {
    // TODO: GET $baseUrl/api/v1/perfil/$userId
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPosts().where((p) => p.userId == userId).toList();
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

// ── Mock data ─────────────────────────────────────────
List<Post> _mockPosts() => [
      Post(
        id: '1',
        userId: 'user1',
        username: 'maria_ups',
        imageUrl: 'https://picsum.photos/seed/ups1/600/600',
        caption: 'Filtro emboss en la práctica de CUDA #UPSGlam',
        likesCount: 24,
        commentsCount: 3,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: '2',
        userId: 'user2',
        username: 'jhon_dev',
        imageUrl: 'https://picsum.photos/seed/ups2/600/600',
        caption: 'Motion blur con tamaño de filtro 125 🔥',
        likesCount: 41,
        commentsCount: 7,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Post(
        id: '3',
        userId: 'user3',
        username: 'sofia_parallel',
        imageUrl: 'https://picsum.photos/seed/ups3/600/600',
        caption: 'Nitidez al máximo, GPU procesando en 12ms',
        likesCount: 18,
        commentsCount: 2,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Post(
        id: '4',
        userId: 'user1',
        username: 'maria_ups',
        imageUrl: 'https://picsum.photos/seed/ups4/600/600',
        caption: null,
        likesCount: 9,
        commentsCount: 0,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

List<Comment> _mockComments(String postId) => [
      Comment(
        id: 'c1',
        postId: postId,
        userId: 'user2',
        username: 'jhon_dev',
        content: 'Qué buen resultado con ese filtro!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Comment(
        id: 'c2',
        postId: postId,
        userId: 'user3',
        username: 'sofia_parallel',
        content: 'Cuánto tiempo tardó la GPU en procesar?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
