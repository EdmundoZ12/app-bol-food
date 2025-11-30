import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/order.dart';

class OrderService {
  final Dio _dio = Dio();
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

  Future<List<Order>> getDriverOrders(String driverId) async {
    try {
      final response = await _dio.get('$_baseUrl/orders/driver/$driverId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching driver orders: $e');
      return [];
    }
  }
}
