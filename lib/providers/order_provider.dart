import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters for filtered lists
  List<Order> get todayOrders {
    final now = DateTime.now();
    return _orders.where((order) {
      return order.createdAt.year == now.year &&
             order.createdAt.month == now.month &&
             order.createdAt.day == now.day;
    }).toList();
  }

  List<Order> get weekOrders {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _orders.where((order) {
      return order.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  Future<void> getDriverOrders(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getDriverOrders(driverId);
      // Sort by date descending
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
