import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String driverId) {
    if (socket != null && _isConnected) {
      print('✅ Ya está conectado al servidor');
      return;
    }

    final baseUrl = dotenv.env['API_URL'] ?? 'http://192.168.0.3:3500';

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.on('connect', (_) {
      print('✅ Conectado al servidor WebSocket');
      _isConnected = true;
      socket!.emit('driver:connect', {'driverId': driverId});
    });

    socket!.on('disconnect', (_) {
      print('❌ Desconectado del servidor');
      _isConnected = false;
    });

    socket!.on('connect_error', (error) {
      print('❌ Error de conexión: $error');
      _isConnected = false;
    });

    // Escuchar actualizaciones de ubicación
    socket!.on('driver:$driverId:location', (data) {
      print('📍 Ubicación actualizada: ${data['latitude']}, ${data['longitude']}');
    });
  }

  void sendLocation(String driverId, double latitude, double longitude) {
    if (!_isConnected || socket == null) {
      print('⚠️ No conectado al servidor');
      return;
    }

    socket!.emit('driver:location', {
      'driverId': driverId,
      'latitude': latitude,
      'longitude': longitude,
    });

    print('📤 Ubicación enviada: $latitude, $longitude');
  }

  void disconnect(String driverId) {
    if (socket != null && _isConnected) {
      socket!.emit('driver:disconnect', {'driverId': driverId});
      socket!.disconnect();
      socket = null;
      _isConnected = false;
      print('🔌 Desconectado del servidor');
    }
  }
}
