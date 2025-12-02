import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class NavigationMapWidget extends StatefulWidget {
  final LatLng destination;
  final String destinationName;
  final VoidCallback? onArrived;

  const NavigationMapWidget({
    super.key,
    required this.destination,
    required this.destinationName,
    this.onArrived,
  });

  @override
  State<NavigationMapWidget> createState() => _NavigationMapWidgetState();
}

class _NavigationMapWidgetState extends State<NavigationMapWidget> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Permisos de ubicación denegados permanentemente');
        return;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Configurar marcadores
      _setupMarkers();

      // Iniciar seguimiento de ubicación
      _startLocationTracking();

      // Ajustar cámara para mostrar ambos puntos
      _fitMapToRoute();
    } catch (e) {
      _showError('Error al obtener ubicación: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupMarkers() {
    _markers.clear();

    // Marcador de ubicación actual
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
      );
    }

    // Marcador de destino
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.destinationName),
      ),
    );

    // Crear línea entre origen y destino
    _getRoute();
  }

  Future<void> _getRoute() async {
    if (_currentPosition == null) return;

    try {
      // Nota: Usamos la misma API Key que en AndroidManifest.xml
      // En producción, esto debería venir de una variable de entorno segura
      const String googleApiKey = "AIzaSyDquTRJzYhHXumYm7p-wKWLTxG1E0ZV4hg";
      
      PolylinePoints polylinePoints = PolylinePoints(apiKey: googleApiKey);

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          destination: PointLatLng(widget.destination.latitude, widget.destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = [];
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        if (mounted) {
          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        }
      }
    } catch (e) {
      print("Error obteniendo ruta: $e");
      // Fallback a línea recta si falla la API
      if (mounted) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: [
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                widget.destination,
              ],
              color: Colors.blue,
              width: 4,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
            ),
          );
        });
      }
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Actualizar cada 10 metros
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _setupMarkers();
      });

      // Mover cámara a la nueva posición
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );

      // Verificar si llegó al destino (dentro de 50 metros)
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.destination.latitude,
        widget.destination.longitude,
      );

      if (distance <= 50 && widget.onArrived != null) {
        widget.onArrived!();
      }
    });
  }

  Future<void> _fitMapToRoute() async {
    if (_currentPosition == null || _mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentPosition!.latitude < widget.destination.latitude
            ? _currentPosition!.latitude
            : widget.destination.latitude,
        _currentPosition!.longitude < widget.destination.longitude
            ? _currentPosition!.longitude
            : widget.destination.longitude,
      ),
      northeast: LatLng(
        _currentPosition!.latitude > widget.destination.latitude
            ? _currentPosition!.latitude
            : widget.destination.latitude,
        _currentPosition!.longitude > widget.destination.longitude
            ? _currentPosition!.longitude
            : widget.destination.longitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  double _calculateDistance() {
    if (_currentPosition == null) return 0;

    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          widget.destination.latitude,
          widget.destination.longitude,
        ) /
        1000; // Convertir a kilómetros
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentPosition == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No se pudo obtener la ubicación',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _fitMapToRoute();
            },
          ),
        ),
        // Distance indicator
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.navigation, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_calculateDistance().toStringAsFixed(2)} km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.destinationName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
