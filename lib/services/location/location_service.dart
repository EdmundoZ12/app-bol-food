import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Verificar y solicitar permisos de ubicación
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Servicios de ubicación deshabilitados');
      return false;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Permisos de ubicación denegados');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Permisos de ubicación denegados permanentemente');
      return false;
    }

    print('✅ Permisos de ubicación concedidos');
    return true;
  }

  /// Obtener ubicación actual
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Ubicación actual: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      return null;
    }
  }

  /// Stream de ubicación para tracking en tiempo real
  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calcular distancia entre dos puntos (en metros)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Abrir configuración de ubicación
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Abrir configuración de la app
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
