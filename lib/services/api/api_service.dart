import 'package:cortada_app/services/auth/auth_service.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final AuthService _authService;

  ApiService({
    required AuthService authService,
  })  : _authService = authService,
        _dio = Dio(BaseOptions(
          baseUrl: 'http://10.0.2.2:3000/api',
          validateStatus: (status) => status! < 500,
        ));

  Future<void> _setupInterceptors() async {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_authService.currentUser != null) {
          final token = await _authService.currentUser!.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _authService.signOut();
        }
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    await _setupInterceptors();
    try {
      final response = await _dio.get('/users/profile');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Erro ao buscar perfil');
      }
    } catch (e) {
      throw Exception('Erro ao buscar perfil: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile() async {
    await _setupInterceptors();
    try {
      final response = await _dio.post('/users/profile');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'Erro ao atualizar perfil');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: ${e.toString()}');
    }
  }

  Future<List<String>> getAuthMethods() async {
    await _setupInterceptors();
    try {
      final response = await _dio.get('/users/auth-methods');

      if (response.statusCode == 200) {
        return List<String>.from(
            response.data.map((m) => m['providerId'] as String));
      } else {
        throw Exception(
            response.data['error'] ?? 'Erro ao buscar métodos de autenticação');
      }
    } catch (e) {
      throw Exception(
          'Erro ao buscar métodos de autenticação: ${e.toString()}');
    }
  }
}
