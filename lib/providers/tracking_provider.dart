import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/socket_service.dart';

class TrackingProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final SocketService _socketService = SocketService();

  Position? _currentPosition;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;
  String? _driverId;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;

  Future<void> startTracking(String driverId) async {
    if (_isTracking) {
      print('⚠️ Tracking ya está activo');
      return;
    }

    _driverId = driverId;

    // Solicitar permisos
    final hasPermission = await _locationService.requestPermissions();
    if (!hasPermission) {
      print('❌ No se otorgaron permisos de ubicación');
      return;
    }

    // Conectar WebSocket
    _socketService.connect(driverId);

    // Obtener ubicación actual
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _currentPosition = position;
      _socketService.sendLocation(driverId, position.latitude, position.longitude);
      notifyListeners();
    }

    // Iniciar stream de ubicación
    _positionSubscription = _locationService.getLocationStream().listen(
      (Position position) {
        _currentPosition = position;
        _socketService.sendLocation(driverId, position.latitude, position.longitude);
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error en stream de ubicación: $error');
      },
    );

    _isTracking = true;
    notifyListeners();
    print('✅ Tracking iniciado');
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    if (_driverId != null) {
      _socketService.disconnect(_driverId!);
    }

    _isTracking = false;
    _currentPosition = null;
    _driverId = null;
    notifyListeners();
    print('⏹️ Tracking detenido');
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
