import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📱 AuthProvider: Iniciando registro de usuario');

      _user = await _authService.register(
        nombre: nombre,
        apellido: apellido,
        email: email,
        password: password,
        telefono: telefono,
      );

      print('📱 AuthProvider: Usuario registrado con éxito');
      print('📱 Usuario: ${_user?.nombre} ${_user?.apellido}');
      print('📱 Email: ${_user?.email}');
      print('📱 ID: ${_user?.id}');

      // Guardar datos básicos del usuario en el almacenamiento seguro
      await _storage.write(key: 'user_id', value: _user?.id.toString());
      await _storage.write(key: 'user_email', value: _user?.email);
      await _storage.write(key: 'user_nombre', value: _user?.nombre);
      await _storage.write(key: 'user_apellido', value: _user?.apellido);

      print(
          '📱 AuthProvider: Datos del usuario guardados en almacenamiento seguro');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en AuthProvider.register: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.login(
        email: email,
        password: password,
      );

      _user = response['user'] as User;
      _token = response['token'] as String;

      // Guardar datos en el almacenamiento seguro
      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'user_id', value: _user?.id.toString());
      await _storage.write(key: 'user_email', value: _user?.email);
      await _storage.write(key: 'user_nombre', value: _user?.nombre);
      await _storage.write(key: 'user_apellido', value: _user?.apellido);

      print('✅ Usuario logueado exitosamente:');
      print('Nombre: ${_user?.nombre} ${_user?.apellido}');
      print('Email: ${_user?.email}');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error en AuthProvider login: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Obtener el email antes de borrar todo
      final email = _user?.email;
      if (email != null) {
        // Eliminar token del dispositivo en el servidor
        await _authService.logout(email);
      }
      print("SE ELIMINO EL TOKEN");

      // Limpiar almacenamiento local
      await _storage.deleteAll();
      _user = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error en logout: $e');
      rethrow;
    }
  }

  Future<bool> checkAuth() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        final id = int.parse(await _storage.read(key: 'user_id') ?? '0');
        final email = await _storage.read(key: 'user_email') ?? '';
        final nombre = await _storage.read(key: 'user_nombre') ?? '';
        final apellido = await _storage.read(key: 'user_apellido') ?? '';

        _user = User(
          id: id,
          email: email,
          nombre: nombre,
          apellido: apellido,
        );
        _token = token;

        // // Actualizar token del dispositivo al restablecer la sesión
        // if (email.isNotEmpty) {
        //   _authService.saveTokenDevice(
        //     email: email,
        //     tokenDevice: await _authService._getFCMToken(),
        //   );
        // }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error en checkAuth: $e');
      return false;
    }
  }
}
