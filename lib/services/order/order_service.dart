import 'package:bol_food_app/config/constants.dart';
import 'package:bol_food_app/models/order/order.dart';
import 'package:dio/dio.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Aceptar pedido
  Future<Order> acceptOrder(String orderId, String token) async {
    try {
      print('📱 OrderService: Aceptando pedido $orderId...');

      final response = await _dio.post(
        '/driver/orders/$orderId/accept',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Pedido aceptado: ${response.data}');
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      print('❌ Error aceptando pedido: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al aceptar pedido';
      throw Exception(message);
    }
  }

  /// Rechazar pedido
  Future<void> rejectOrder(String orderId, String token) async {
    try {
      print('📱 OrderService: Rechazando pedido $orderId...');

      await _dio.post(
        '/driver/orders/$orderId/reject',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Pedido rechazado');
    } on DioException catch (e) {
      print('❌ Error rechazando pedido: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al rechazar pedido';
      throw Exception(message);
    }
  }

  /// Actualizar estado: Voy al restaurante
  Future<Order> markPickingUp(String orderId, String token) async {
    try {
      print('📱 OrderService: Marcando PICKING_UP...');

      final response = await _dio.patch(
        '/driver/orders/$orderId/picking-up',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estado actualizado a PICKING_UP');
      print('📱 Response data: ${response.data}');
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      print('❌ Error actualizando estado: ${e.response?.data}');
      final message =
          e.response?.data['message'] ?? 'Error al actualizar estado';
      throw Exception(message);
    }
  }

  /// Actualizar estado: Recogí el pedido
  Future<Order> markPickedUp(String orderId, String token) async {
    try {
      print('📱 OrderService: Marcando PICKED_UP...');

      final response = await _dio.patch(
        '/driver/orders/$orderId/picked-up',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estado actualizado a PICKED_UP');
      print('📱 Response data: ${response.data}');
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      print('❌ Error actualizando estado: ${e.response?.data}');
      final message =
          e.response?.data['message'] ?? 'Error al actualizar estado';
      throw Exception(message);
    }
  }

  /// Actualizar estado: En camino al cliente
  Future<Order> markInTransit(String orderId, String token) async {
    try {
      print('📱 OrderService: Marcando IN_TRANSIT...');

      final response = await _dio.patch(
        '/driver/orders/$orderId/in-transit',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estado actualizado a IN_TRANSIT');
      print('📱 Response data: ${response.data}');
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      print('❌ Error actualizando estado: ${e.response?.data}');
      final message =
          e.response?.data['message'] ?? 'Error al actualizar estado';
      throw Exception(message);
    }
  }

  /// Actualizar estado: En la puerta del cliente
  Future<Order> markAtDoor(String orderId, String token) async {
    try {
      print('📱 OrderService: Marcando AT_DOOR...');

      final response = await _dio.patch(
        '/driver/orders/$orderId/at-door',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estado actualizado a AT_DOOR');
      print('📱 Response data: ${response.data}');
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      print('❌ Error actualizando estado: ${e.response?.data}');
      final message =
          e.response?.data['message'] ?? 'Error al actualizar estado';
      throw Exception(message);
    }
  }

  /// Actualizar estado: Entregado
  Future<Order> markDelivered(String orderId, String token) async {
    try {
      print('📱 OrderService: Marcando DELIVERED...');

      final response = await _dio.patch(
        '/driver/orders/$orderId/delivered',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Estado actualizado a DELIVERED');
      print('📱 Response data: ${response.data}');
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      print('❌ Error actualizando estado: ${e.response?.data}');
      final message =
          e.response?.data['message'] ?? 'Error al actualizar estado';
      throw Exception(message);
    }
  }

  /// Obtener detalles de un pedido
  Future<Order> getOrder(String orderId, String token) async {
    try {
      print('📱 OrderService: Obteniendo pedido $orderId...');

      final response = await _dio.get(
        '/orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Pedido obtenido');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Error obteniendo pedido: ${e.response?.data}');
      final message = e.response?.data['message'] ?? 'Error al obtener pedido';
      throw Exception(message);
    }
  }

  /// Obtener pedidos del driver
  Future<List<Order>> getDriverOrders(String driverId, String token) async {
    try {
      print('📱 OrderService: Obteniendo pedidos del driver...');

      final response = await _dio.get(
        '/orders/driver/$driverId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Pedidos obtenidos: ${response.data.length}');
      return (response.data as List)
          .map((order) => Order.fromJson(order))
          .toList();
    } on DioException catch (e) {
      print('❌ Error obteniendo pedidos: ${e.response?.data}');
      return [];
    }
  }
}
