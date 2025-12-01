import 'package:dio/dio.dart';
import '../../config/constants.dart';
import '../../models/auth/driver.dart';
import '../../utils/variables.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Registrar nuevo driver
  Future<Driver> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String vehicle,
  }) async {
    try {
      print('📱 AuthService: Registrando driver...');
      print('📱 AppToken actual: $tokenDevice');

      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: {
          'name': name,
          'lastname': lastname,
          'email': email,
          'password': password,
          'phone': phone,
          'vehicle': vehicle,
          'appToken': tokenDevice.isNotEmpty ? tokenDevice : null,
        },
      );

      print('✅ Registro exitoso: ${response.data}');
      return Driver.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error en registro: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al registrar';
      throw Exception(message);
    }
  }

  /// Login del driver
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📱 AuthService: Iniciando login...');
      print('📱 AppToken actual: $tokenDevice');

      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
          'appToken': tokenDevice.isNotEmpty ? tokenDevice : null,
        },
      );

      print('✅ Login exitoso: ${response.data}');

      return {
        'driver': Driver.fromJson(response.data['driver']),
        'token': response.data['access_token'],
      };
    } on DioException catch (e) {
      print('❌ Error en login: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Credenciales inválidas';
      throw Exception(message);
    }
  }

  /// Logout del driver
  Future<void> logout(String token) async {
    try {
      print('📱 AuthService: Cerrando sesión...');

      await _dio.post(
        AppConstants.logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Logout exitoso - appToken limpiado y status OFFLINE');
    } on DioException catch (e) {
      print('❌ Error en logout: ${e.response?.data}');
    }
  }

  /// Obtener perfil del driver
  Future<Driver> getProfile(String token) async {
    try {
      final response = await _dio.get(
        AppConstants.profileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Driver.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error obteniendo perfil: ${e.response?.data}');
      throw Exception('Error al obtener perfil');
    }
  }
}
