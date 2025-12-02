import 'dart:async';
import 'package:bol_food_app/services/auth/driver_service.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class TrackingService {
  final LocationService _locationService = LocationService();
  final DriverService _driverService = DriverService();

  Timer? _sendLocationTimer;
  bool _isTracking = false;
  String? _driverId;
  String? _token;

  bool get isTracking => _isTracking;

  /// Iniciar tracking y envío de ubicación al backend
  Future<void> startTracking({
    required String driverId,
    required String token,
    int sendIntervalSeconds = 15, // Enviar cada 15 segundos
  }) async {
    if (_isTracking) {
      print('⚠️ Tracking ya está activo');
      return;
    }

    _driverId = driverId;
    _token = token;

    // Verificar permisos
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      print('❌ No hay permisos de ubicación');
      return;
    }

    // Obtener ubicación inicial y enviar
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      await _sendLocationToBackend(position);
    }

    // Iniciar tracking continuo
    _locationService.startTracking(
      onLocationUpdate: (position) {
        // Guardamos la última posición, pero no enviamos en cada cambio
        // para evitar saturar el servidor
      },
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    // Timer para enviar ubicación periódicamente
    _sendLocationTimer = Timer.periodic(
      Duration(seconds: sendIntervalSeconds),
      (_) async {
        final lastPosition = _locationService.lastPosition;
        if (lastPosition != null) {
          await _sendLocationToBackend(lastPosition);
        }
      },
    );

    _isTracking = true;
    print('🚀 Tracking iniciado - Enviando cada $sendIntervalSeconds segundos');
  }

  /// Enviar ubicación al backend
  Future<void> _sendLocationToBackend(Position position) async {
    if (_driverId == null || _token == null) return;

    final success = await _driverService.updateLocation(
      _driverId!,
      position.latitude,
      position.longitude,
      _token!,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
    );

    if (success) {
      print(
        '📤 Ubicación enviada: ${position.latitude}, ${position.longitude}',
      );
    }
  }

  /// Detener tracking
  void stopTracking() {
    _sendLocationTimer?.cancel();
    _sendLocationTimer = null;
    _locationService.stopTracking();
    _isTracking = false;
    _driverId = null;
    _token = null;
    print('🛑 Tracking detenido');
  }

  /// Obtener última ubicación conocida
  Position? getLastPosition() {
    return _locationService.lastPosition;
  }

  /// Enviar ubicación manualmente (una sola vez)
  Future<bool> sendCurrentLocation({
    required String driverId,
    required String token,
  }) async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) return false;

    return _driverService.updateLocation(
      driverId,
      position.latitude,
      position.longitude,
      token,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
    );
  }

  /// Liberar recursos
  void dispose() {
    stopTracking();
    _locationService.dispose();
  }
}
