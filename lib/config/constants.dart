import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // URL base desde variable de entorno
  static String get baseUrl =>
      dotenv.env['API_URL'] ?? 'http://10.0.2.2:3500/api';

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String registerEndpoint = '/drivers/register';

  // Driver Order Endpoints
  static const String acceptOrderEndpoint =
      '/driver/orders'; // /:orderId/accept
  static const String rejectOrderEndpoint =
      '/driver/orders'; // /:orderId/reject
  static const String pickingUpEndpoint =
      '/driver/orders'; // /:orderId/picking-up
  static const String pickedUpEndpoint =
      '/driver/orders'; // /:orderId/picked-up
  static const String inTransitEndpoint =
      '/driver/orders'; // /:orderId/in-transit
  static const String deliveredEndpoint =
      '/driver/orders'; // /:orderId/delivered

  // Order Endpoints
  static const String ordersEndpoint = '/orders';

  // Ubicación del restaurante (hardcoded para este proyecto)
  static const double restaurantLatitude = -17.783294883950212;
  static const double restaurantLongitude = -63.18213281010442;
  static const String restaurantName = 'BolFood Restaurant';
  static const String restaurantAddress = 'Av Cañoto #4571';
  static const String restaurantPhone = '+591 725 854 12';
}
