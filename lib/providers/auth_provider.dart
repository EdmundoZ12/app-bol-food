import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/driver.dart';
import '../services/auth_service.dart';

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _authStatus = AuthStatus.checking;
  Driver? _driver;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AuthStatus get authStatus => _authStatus;
  Driver? get driver => _driver;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;

  AuthProvider() {
    checkAuth();
  }

  /// Registrar nuevo driver
  Future<bool> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String vehicle,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📱 AuthProvider: Iniciando registro...');

      _driver = await _authService.register(
        name: name,
        lastname: lastname,
        email: email,
        password: password,
        phone: phone,
        vehicle: vehicle,
      );

      print('✅ Driver registrado: ${_driver?.fullName}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en registro: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login del driver
  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📱 AuthProvider: Iniciando login...');

      final response = await _authService.login(
        email: email,
        password: password,
      );

      _driver = response['driver'] as Driver;
      _token = response['token'] as String;

      // Guardar en almacenamiento seguro
      await _saveToStorage();

      _authStatus = AuthStatus.authenticated;

      print('✅ Login exitoso: ${_driver?.fullName}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en login: $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _authStatus = AuthStatus.notAuthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      print('📱 AuthProvider: Cerrando sesión...');

      if (_token != null) {
        await _authService.logout(_token!);
      }

      await _clearStorage();

      _driver = null;
      _token = null;
      _authStatus = AuthStatus.notAuthenticated;

      print('✅ Sesión cerrada');
      notifyListeners();
    } catch (e) {
      print('❌ Error en logout: $e');
      // Limpiar de todos modos
      await _clearStorage();
      _driver = null;
      _token = null;
      _authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
    }
  }

  /// Actualizar estado del driver
  Future<void> updateDriverStatus(String newStatus) async {
    try {
      if (_driver == null || _token == null) return;

      print('📱 AuthProvider: Actualizando estado a $newStatus...');

      // Aquí deberías hacer la llamada al backend para actualizar el estado
      // Por ahora solo actualizamos localmente
      _driver = Driver(
        id: _driver!.id,
        email: _driver!.email,
        name: _driver!.name,
        lastname: _driver!.lastname,
        phone: _driver!.phone,
        vehicle: _driver!.vehicle,
        status: newStatus,
        isActive: _driver!.isActive,
      );

      print('✅ Estado actualizado a: $newStatus');
      notifyListeners();
    } catch (e) {
      print('❌ Error actualizando estado: $e');
      rethrow;
    }
  }

  /// Verificar autenticación al iniciar la app
  Future<void> checkAuth() async {
    try {
      print('📱 AuthProvider: Verificando autenticación...');

      final token = await _storage.read(key: 'token');

      if (token == null) {
        print('📱 No hay token guardado');
        _authStatus = AuthStatus.notAuthenticated;
        notifyListeners();
        return;
      }

      // Intentar obtener el perfil con el token guardado
      _token = token;
      _driver = await _authService.getProfile(token);
      _authStatus = AuthStatus.authenticated;

      print('✅ Sesión restaurada: ${_driver?.fullName}');
      notifyListeners();
    } catch (e) {
      print('❌ Token inválido o expirado: $e');
      await _clearStorage();
      _authStatus = AuthStatus.notAuthenticated;
      notifyListeners();
    }
  }

  /// Guardar datos en almacenamiento seguro
  Future<void> _saveToStorage() async {
    await _storage.write(key: 'token', value: _token);
    await _storage.write(key: 'driver_id', value: _driver?.id);
    await _storage.write(key: 'driver_email', value: _driver?.email);
    await _storage.write(key: 'driver_name', value: _driver?.name);
    await _storage.write(key: 'driver_lastname', value: _driver?.lastname);
  }

  /// Limpiar almacenamiento
  Future<void> _clearStorage() async {
    await _storage.deleteAll();
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
