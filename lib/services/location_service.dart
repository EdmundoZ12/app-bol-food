import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      // Solicitar permiso de ubicación en segundo plano (Android 10+)
      if (await Permission.locationAlways.isDenied) {
        await Permission.locationAlways.request();
      }
      return true;
    }
    
    return false;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('⚠️ Permiso de ubicación denegado');
        return null;
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Servicio de ubicación desactivado');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      ),
    );
  }

  Future<double> getDistanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    ) / 1000; // Convertir a kilómetros
  }
}
