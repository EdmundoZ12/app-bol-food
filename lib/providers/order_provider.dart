import 'package:bol_food_app/models/order/order.dart';
import 'package:bol_food_app/services/order/order_service.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  Order? _currentOrder;
  Order? _incomingOrder;
  List<Order> _orderHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Order? get currentOrder => _currentOrder;
  Order? get incomingOrder => _incomingOrder;
  List<Order> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveOrder => _currentOrder != null;
  bool get hasIncomingOrder => _incomingOrder != null;

  /// Establecer pedido entrante (desde notificación push)
  void setIncomingOrder(Order order) {
    _incomingOrder = order;
    notifyListeners();
  }

  /// Establecer pedido entrante desde datos de notificación
  void setIncomingOrderFromNotification(Map<String, dynamic> data) {
    print('📱 OrderProvider: Procesando notificación de nuevo pedido');
    print('📱 Data recibida: $data');

    // Crear un Order básico desde los datos de la notificación
    // Los detalles completos se obtienen al aceptar
    _incomingOrder = Order(
      id: data['orderId'] ?? '',
      totalAmount: double.tryParse(data['estimatedEarnings'] ?? '0') ?? 0,
      status: OrderStatus.assigned,
      deliveryDistance: double.tryParse(data['distanceKm'] ?? '0'),
      driverEarnings: double.tryParse(data['estimatedEarnings'] ?? '0'),
    );

    notifyListeners();
  }

  /// Limpiar pedido entrante
  void clearIncomingOrder() {
    _incomingOrder = null;
    notifyListeners();
  }

  /// Aceptar pedido
  Future<bool> acceptOrder(String driverId, String token) async {
    if (_incomingOrder == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final order = await _orderService.acceptOrder(_incomingOrder!.id, driverId, token);

      _currentOrder = order;
      _incomingOrder = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error aceptando pedido: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Rechazar pedido
  Future<bool> rejectOrder(String driverId, String token) async {
    if (_incomingOrder == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _orderService.rejectOrder(_incomingOrder!.id, driverId, token);

      _incomingOrder = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error rechazando pedido: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Marcar: Llegué al restaurante
  Future<bool> arrivedAtRestaurant(String driverId, String token) async {
    if (_currentOrder == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final order = await _orderService.arrivedAtRestaurant(_currentOrder!.id, driverId, token);
      _currentOrder = order;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Marcar: Confirmar recogida del pedido
  Future<bool> confirmPickup(String driverId, String token) async {
    if (_currentOrder == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final order = await _orderService.confirmPickup(_currentOrder!.id, driverId, token);
      _currentOrder = order;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Marcar: Estoy en la puerta del cliente
  Future<bool> atCustomerDoor(String driverId, String token) async {
    if (_currentOrder == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final order = await _orderService.atCustomerDoor(_currentOrder!.id, driverId, token);
      _currentOrder = order;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Marcar: Confirmar entrega
  Future<bool> confirmDelivery(String driverId, String token) async {
    if (_currentOrder == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final order = await _orderService.confirmDelivery(_currentOrder!.id, driverId, token);

      // Agregar a historial
      _orderHistory.insert(0, order);
      _currentOrder = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtener detalles completos del pedido actual
  Future<void> refreshCurrentOrder(String token) async {
    if (_currentOrder == null) return;

    try {
      final order = await _orderService.getOrderDetails(_currentOrder!.id, token);
      _currentOrder = order;
      notifyListeners();
    } catch (e) {
      print('❌ Error refrescando pedido: $e');
    }
  }

  /// Obtener historial de pedidos
  Future<void> loadOrderHistory(String driverId, String token) async {
    try {
      _orderHistory = await _orderService.getDriverOrders(driverId, token);
      notifyListeners();
    } catch (e) {
      print('❌ Error cargando historial: $e');
    }
  }

  /// Limpiar pedido actual
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
