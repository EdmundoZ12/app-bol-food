import 'package:dio/dio.dart';
import '../../config/constants.dart';
import '../../models/order/order.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Aceptar un pedido
  Future<Order> acceptOrder(String orderId, String driverId, String token) async {
    try {
      print('📱 OrderService: Aceptando pedido $orderId');

      final response = await _dio.post(
        '/orders/$orderId/accept',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Pedido aceptado exitosamente');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error aceptando pedido: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al aceptar pedido';
      throw Exception(message);
    }
  }

  /// Rechazar un pedido
  Future<Order> rejectOrder(String orderId, String driverId, String token) async {
    try {
      print('📱 OrderService: Rechazando pedido $orderId');

      final response = await _dio.post(
        '/orders/$orderId/reject',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Pedido rechazado exitosamente');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error rechazando pedido: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al rechazar pedido';
      throw Exception(message);
    }
  }

  /// Marcar llegada al restaurante
  Future<Order> arrivedAtRestaurant(String orderId, String driverId, String token) async {
    try {
      print('📱 OrderService: Marcando llegada al restaurante');

      final response = await _dio.post(
        '/orders/$orderId/arrived-restaurant',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Llegada al restaurante marcada');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error marcando llegada: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al marcar llegada';
      throw Exception(message);
    }
  }

  /// Confirmar recogida del pedido
  Future<Order> confirmPickup(String orderId, String driverId, String token) async {
    try {
      print('📱 OrderService: Confirmando recogida del pedido');

      final response = await _dio.post(
        '/orders/$orderId/confirm-pickup',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Recogida confirmada');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error confirmando recogida: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al confirmar recogida';
      throw Exception(message);
    }
  }

  /// Marcar llegada a la puerta del cliente
  Future<Order> atCustomerDoor(String orderId, String driverId, String token) async {
    try {
      print('📱 OrderService: Marcando llegada a la puerta');

      final response = await _dio.post(
        '/orders/$orderId/at-door',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Llegada a la puerta marcada');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error marcando llegada a la puerta: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al marcar llegada';
      throw Exception(message);
    }
  }

  /// Confirmar entrega del pedido
  Future<Order> confirmDelivery(String orderId, String driverId, String token) async {
    try {
      print('📱 OrderService: Confirmando entrega del pedido');

      final response = await _dio.post(
        '/orders/$orderId/confirm-delivery',
        data: {'driverId': driverId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Entrega confirmada');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error confirmando entrega: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al confirmar entrega';
      throw Exception(message);
    }
  }

  /// Obtener detalles de un pedido
  Future<Order> getOrderDetails(String orderId, String token) async {
    try {
      print('📱 OrderService: Obteniendo detalles del pedido $orderId');

      final response = await _dio.get(
        '/orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error obteniendo detalles: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al obtener pedido';
      throw Exception(message);
    }
  }

  /// Obtener pedidos del conductor
  Future<List<Order>> getDriverOrders(String driverId, String token) async {
    try {
      final response = await _dio.get(
        '/orders/driver/$driverId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final ordersJson = response.data as List;
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener órdenes del conductor: $e');
    }
  }

  /// Obtener pedido activo del conductor
  Future<Order?> getActiveOrder(String driverId, String token) async {
    try {
      final response = await _dio.get(
        '/orders/driver/$driverId/active',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print(' getActiveOrder response: ${response.statusCode} - ${response.data}');

      if (response.data == null || response.data == '') {
        return null;
      }

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor: ${response.data}');
      }

      return Order.fromJson(response.data);
    } catch (e) {
      // Si no hay pedido activo, el backend retorna null
      if (e.toString().contains('404')) {
        return null;
      }
      throw Exception('Error al obtener pedido activo: $e');
    }
  }
}
