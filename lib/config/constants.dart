import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // URL base desde variable de entorno
  static String get baseUrl =>
      dotenv.env['API_URL'] ?? 'http://10.0.2.2:3500/api';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String registerEndpoint = '/drivers/register';
}
