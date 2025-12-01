import 'package:dio/dio.dart';
import '../models/order.dart';

class OrderService {
  final Dio dio;

  OrderService(this.dio);

  // Obtener pedidos pendientes de asignación
  Future<List<Order>> getPendingOrders() async {
    try {
      final response = await dio.get('/orders/pending-assignment');
      return (response.data as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo pedidos pendientes: $e');
      rethrow;
    }
  }

  // Obtener pedidos del driver
  Future<List<Order>> getDriverOrders(String driverId) async {
    try {
      final response = await dio.get('/orders/driver/$driverId');
      return (response.data as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error obteniendo pedidos del driver: $e');
      rethrow;
    }
  }

  // Obtener un pedido específico
  Future<Order> getOrder(String orderId) async {
    try {
      final response = await dio.get('/orders/$orderId');
      return Order.fromJson(response.data);
    } catch (e) {
      print('❌ Error obteniendo pedido: $e');
      rethrow;
    }
  }

  // Aceptar pedido
  Future<Order> acceptOrder(String orderId, String driverId) async {
    try {
      final response = await dio.post(
        '/orders/$orderId/accept',
        data: {'driverId': driverId},
      );
      print('✅ Pedido aceptado');
      return Order.fromJson(response.data);
    } catch (e) {
      print('❌ Error aceptando pedido: $e');
      rethrow;
    }
  }

  // Rechazar pedido
  Future<void> rejectOrder(String orderId, String driverId) async {
    try {
      await dio.post(
        '/orders/$orderId/reject',
        data: {'driverId': driverId},
      );
      print('✅ Pedido rechazado');
    } catch (e) {
      print('❌ Error rechazando pedido: $e');
      rethrow;
    }
  }

  // Actualizar estado del pedido
  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await dio.patch(
        '/orders/$orderId/driver-status',
        data: {'status': status},
      );
      print('✅ Estado actualizado a: $status');
      return Order.fromJson(response.data);
    } catch (e) {
      print('❌ Error actualizando estado: $e');
      rethrow;
    }
  }

  // Marcar como entregado
  Future<Order> markAsDelivered(String orderId) async {
    try {
      final response = await dio.patch('/orders/$orderId/delivered');
      print('✅ Pedido marcado como entregado');
      return Order.fromJson(response.data);
    } catch (e) {
      print('❌ Error marcando como entregado: $e');
      rethrow;
    }
  }

  // Obtener estadísticas del driver
  Future<Map<String, dynamic>> getDriverStats(String driverId) async {
    try {
      final response = await dio.get('/drivers/$driverId/stats');
      return response.data;
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      rethrow;
    }
  }
}
