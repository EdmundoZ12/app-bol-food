import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/order/order.dart';
import 'order_service.dart';

class OrderPollingService extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  Timer? _pollingTimer;
  Order? _activeOrder;
  bool _isPolling = false;

  Order? get activeOrder => _activeOrder;
  bool get isPolling => _isPolling;

  /// Iniciar polling para buscar pedidos asignados
  void startPolling(String driverId, String token) {
    if (_isPolling) return;

    _isPolling = true;
    notifyListeners();

    // Polling cada 5 segundos
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkForActiveOrder(driverId, token);
    });

    // Primera verificación inmediata
    _checkForActiveOrder(driverId, token);
  }

  /// Detener polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    notifyListeners();
  }

  /// Verificar si hay un pedido activo
  Future<void> _checkForActiveOrder(String driverId, String token) async {
    try {
      final order = await _orderService.getActiveOrder(driverId, token);
      
      if (order != null) {
        // Solo notificar si es un pedido nuevo o cambió el estado
        if (_activeOrder == null || 
            _activeOrder!.id != order.id || 
            _activeOrder!.status != order.status) {
          print('✅ Polling: Nuevo pedido activo encontrado: ${order.id}');
          _activeOrder = order;
          notifyListeners();
        }
      } else {
        if (_activeOrder != null) {
          print('⚠️ Polling: Pedido activo limpiado (backend devolvió null)');
          _activeOrder = null;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error checking for active order: $e');
    }
  }

  /// Limpiar pedido activo
  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
