import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Singleton para evitar múltiples instancias
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  Position? get lastPosition => _lastPosition;

  /// Verificar y solicitar permisos de ubicación
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Servicio de ubicación deshabilitado');
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Permiso de ubicación denegado');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Permiso de ubicación denegado permanentemente');
      return false;
    }

    print('✅ Permiso de ubicación concedido');
    return true;
  }

  /// Obtener ubicación actual una sola vez
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastPosition = position;
      print('📍 Ubicación actual: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Iniciar tracking continuo de ubicación
  void startTracking({
    required Function(Position) onLocationUpdate,
    int distanceFilter = 10, // metros mínimos para nueva actualización
  }) {
    // Evitar iniciar múltiples streams
    if (_positionSubscription != null) {
      print('⚠️ Tracking ya está activo, ignorando nueva solicitud');
      return;
    }

    print('🚀 Iniciando tracking de ubicación...');

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: distanceFilter,
          ),
        ).listen(
          (Position position) {
            _lastPosition = position;
            print(
              '📍 Nueva ubicación: ${position.latitude}, ${position.longitude}',
            );
            onLocationUpdate(position);
          },
          onError: (error) {
            print('❌ Error en tracking: $error');
          },
        );
  }

  /// Detener tracking de ubicación
  void stopTracking() {
    print('🛑 Deteniendo tracking de ubicación');
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calcular distancia entre dos puntos en metros
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Liberar recursos
  void dispose() {
    stopTracking();
  }
}
