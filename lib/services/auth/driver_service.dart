import 'package:bol_food_app/config/constants.dart';
import 'package:bol_food_app/models/auth/driver_stats.dart';
import 'package:dio/dio.dart';

class DriverService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Obtener estadísticas del driver
  Future<DriverStats> getStats(String token) async {
    try {
      print('📱 DriverService: Obteniendo estadísticas...');

      final response = await _dio.get(
        '/driver/stats',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estadísticas obtenidas: ${response.data}');
      return DriverStats.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error obteniendo estadísticas: ${e.response?.data}');
      return DriverStats.empty();
    }
  }

  /// Actualizar estado del driver (AVAILABLE/OFFLINE)
  Future<bool> updateStatus(
    String driverId,
    String status,
    String token,
  ) async {
    try {
      print('📱 DriverService: Actualizando estado a $status...');

      await _dio.patch(
        '/drivers/$driverId/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estado actualizado a $status');
      return true;
    } on DioException catch (e) {
      print('❌ Error actualizando estado: ${e.response?.data}');
      return false;
    }
  }

  /// Actualizar ubicación del driver
  Future<bool> updateLocation(
    String driverId,
    double latitude,
    double longitude,
    String token, {
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    try {
      await _dio.post(
        '/drivers/$driverId/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'speed': speed,
          'heading': heading,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } on DioException catch (e) {
      print('❌ Error actualizando ubicación: ${e.response?.data}');
      return false;
    }
  }
}
