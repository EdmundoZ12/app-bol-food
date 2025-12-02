import 'package:bol_food_app/models/auth/driver_stats.dart';
import 'package:bol_food_app/services/auth/driver_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/order/order_polling_service.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/location/location_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/incoming_order_modal.dart';
import '../../models/order/order.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _isOnline = false;
  bool _isLoadingStats = true;
  bool _isTogglingStatus = false;
  DriverStats _stats = DriverStats.empty();

  // Variables para controlar la navegación automática y evitar bucles
  String? _lastNavigatedOrderId;
  OrderStatus? _lastNavigatedStatus;

  final DriverService _driverService = DriverService();
  final LocationService _locationService = LocationService();
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _syncOnlineStatus();
    _updateFCMToken();
    
    // Retrasar el inicio de servicios pesados para evitar sobrecarga inicial y crashes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _startLocationTracking();
          _startPolling();
          context.read<OrderPollingService>().addListener(_handlePollingUpdate);
        }
      });
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    context.read<OrderPollingService>().removeListener(_handlePollingUpdate);
    _stopPolling();
    super.dispose();
  }

  Future<void> _updateFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      
      if (token != null && authProvider.token != null && authProvider.driver != null) {
        print('📱 Actualizando FCM Token: $token');
        await _driverService.updateAppToken(
          authProvider.driver!.id,
          token,
          authProvider.token!,
        );
      }
    } catch (e) {
      print('❌ Error actualizando FCM Token: $e');
    }
  }

  void _startLocationTracking() async {
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) return;

    // Actualizar ubicación inicial
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      _sendLocationUpdate(position);
    }

    // Actualizar cada 30 segundos
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
       if (!mounted) return;
       final pos = await _locationService.getCurrentLocation();
       if (pos != null) _sendLocationUpdate(pos);
    });
  }

  Future<void> _sendLocationUpdate(Position position) async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.token != null && authProvider.driver != null) {
      // Solo enviar si está ONLINE (AVAILABLE o BUSY)
      // Pero para la primera vez, enviamos igual para que el sistema sepa dónde está
      
      await _driverService.updateLocation(
        authProvider.driver!.id,
        position.latitude,
        position.longitude,
        authProvider.token!,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
      );
    }
  }

  void _startPolling() {
    final authProvider = context.read<AuthProvider>();
    final pollingService = context.read<OrderPollingService>();
    
    if (authProvider.isAuthenticated && authProvider.driver != null) {
      pollingService.startPolling(
        authProvider.driver!.id,
        authProvider.token!,
      );
    }
  }

  void _stopPolling() {
    final pollingService = context.read<OrderPollingService>();
    pollingService.stopPolling();
  }

  void _handlePollingUpdate() {
    if (!mounted) return;

    final pollingService = context.read<OrderPollingService>();
    final activeOrder = pollingService.activeOrder;
    final orderProvider = context.read<OrderProvider>();

    if (activeOrder == null) return;

    // Si el pedido está en estado ASSIGNED, lo tratamos como pedido entrante
    if (activeOrder.status == OrderStatus.assigned) {
      // Solo actualizar si es diferente al actual para evitar redibujados innecesarios
      if (orderProvider.incomingOrder?.id != activeOrder.id) {
        orderProvider.setIncomingOrder(activeOrder);
      }
      return;
    }

    // Si el pedido ya fue aceptado (no es ASSIGNED), limpiamos el incomingOrder si existe
    if (orderProvider.incomingOrder?.id == activeOrder.id) {
      orderProvider.clearIncomingOrder();
    }

    // Navegación basada en estado
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      
      // Evitar navegar repetidamente a la misma orden y estado
      if (_lastNavigatedOrderId == activeOrder.id && 
          _lastNavigatedStatus == activeOrder.status) {
        return;
      }

      final String location = GoRouterState.of(context).uri.toString();
      
      // Solo redirigir si estamos en la pantalla de inicio
      // Esto evita interferir con la navegación cuando el usuario ya está en el flujo
      if (location != '/home' && location != '/') return;
      
      bool navigated = false;
      if (activeOrder.status == OrderStatus.accepted || 
          activeOrder.status == OrderStatus.pickingUp) {
        context.push('/order/navigate-restaurant', extra: activeOrder);
        navigated = true;
      } else if (activeOrder.status == OrderStatus.pickedUp ||
                 activeOrder.status == OrderStatus.inTransit || 
                 activeOrder.status == OrderStatus.atPlace) {
        context.push('/order/navigate-customer', extra: activeOrder);
        navigated = true;
      }
      
      if (navigated) {
        _lastNavigatedOrderId = activeOrder.id;
        _lastNavigatedStatus = activeOrder.status;
      }
    });
  }

  void _syncOnlineStatus() {
    final authProvider = context.read<AuthProvider>();
    final driver = authProvider.driver;
    if (driver != null) {
      setState(() {
        _isOnline = driver.isAvailable;
      });
    }
  }

  Future<void> _loadStats() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    if (token == null) return;

    setState(() => _isLoadingStats = true);

    final stats = await _driverService.getStats(token);

    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final driver = authProvider.driver;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(driver, orderProvider, authProvider),
              ),
            ],
          ),

          // Modal de nuevo pedido
          if (orderProvider.hasIncomingOrder && _isOnline)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: IncomingOrderModal(
                    order: orderProvider.incomingOrder!,
                    onAccept: () => _acceptOrder(orderProvider, authProvider),
                    onReject: () => _rejectOrder(orderProvider, authProvider),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(color: primaryBlack),
      child: Row(
        children: [
          Icon(Icons.delivery_dining, color: primaryYellow, size: 28),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.montserratAlternates(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              children: const [
                TextSpan(
                  text: 'Bol',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Food',
                  style: TextStyle(color: primaryYellow),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    driver,
    OrderProvider orderProvider,
    AuthProvider authProvider,
  ) {
    if (orderProvider.hasActiveOrder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ya no redirigimos aquí manualmente, dejamos que el polling lo haga
        // context.push('/active-order'); 
      });
      return const Center(
        child: CircularProgressIndicator(color: primaryYellow),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: primaryYellow,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Bienvenido',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Toggle Online/Offline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildOnlineToggle(authProvider),
            ),
            const SizedBox(height: 20),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatsCard(),
            ),
            const SizedBox(height: 32),

            // Estado esperando
            _buildWaitingState(),
            const SizedBox(height: 24),

            // Info del conductor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDriverInfo(driver),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineToggle(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isOnline ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'En línea' : 'Desconectado',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isOnline ? 'Recibiendo pedidos' : 'Fuera de línea',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _isTogglingStatus
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryYellow,
                  ),
                )
              : Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: _isOnline,
                    onChanged: (value) =>
                        _toggleOnlineStatus(value, authProvider),
                    activeColor: Colors.white,
                    activeTrackColor: primaryYellow,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final now = DateTime.now();
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final dateStr = '${now.day} ${months[now.month - 1]}. ${now.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen de hoy',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                dateStr,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingStats)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: primaryYellow),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        Icons.check_circle_outline,
                        'Entregas',
                        '${_stats.todayDeliveries}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        Icons.attach_money,
                        'Ganancias',
                        _stats.todayEarningsText,
                        isHighlight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        Icons.access_time,
                        'Horas',
                        _stats.hoursWorkedText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        Icons.trending_up,
                        'Aceptación',
                        _stats.acceptanceRateText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7), // Amarillo claro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEDC2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: isHighlight ? primaryYellow : Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserratAlternates(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlight ? primaryYellow : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserratAlternates(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _isOnline
                  ? primaryYellow.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isOnline ? Icons.delivery_dining : Icons.power_settings_new,
              size: 50,
              color: _isOnline ? primaryYellow : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isOnline ? 'Esperando pedidos...' : 'Estás fuera de línea...',
            style: GoogleFonts.montserratAlternates(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isOnline
                ? 'Los pedidos aparecerán automáticamente'
                : 'Activa el modo en línea para recibir pedidos',
            style: GoogleFonts.montserratAlternates(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(driver) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person,
            'Conductor',
            driver?.fullName ?? 'No disponible',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.two_wheeler,
            'Vehículo',
            driver?.vehicle ?? 'No registrado',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone,
            'Teléfono',
            driver?.phone ?? 'No registrado',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: primaryYellow),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.montserratAlternates(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.montserratAlternates(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleOnlineStatus(
    bool value,
    AuthProvider authProvider,
  ) async {
    final driver = authProvider.driver;
    final token = authProvider.token;

    if (driver == null || token == null) return;

    setState(() => _isTogglingStatus = true);

    final newStatus = value ? 'AVAILABLE' : 'OFFLINE';
    final success = await _driverService.updateStatus(
      driver.id,
      newStatus,
      token,
    );

    if (success) {
      setState(() {
        _isOnline = value;
        _isTogglingStatus = false;
      });

      // Recargar perfil para actualizar el estado
      await authProvider.checkAuth();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Ahora estás en línea' : 'Ahora estás fuera de línea',
            ),
            backgroundColor: value ? Colors.green : Colors.grey,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      setState(() => _isTogglingStatus = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar estado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _acceptOrder(
    OrderProvider orderProvider,
    AuthProvider authProvider,
  ) async {
    final token = authProvider.token;
    final driverId = authProvider.driver?.id;
    if (token == null || driverId == null) return;

    final success = await orderProvider.acceptOrder(driverId, token);
    if (success && mounted) {
      // Limpiar el modal inmediatamente
      orderProvider.clearIncomingOrder();
      
      // Forzar actualización del polling para que detecte el cambio de estado y navegue
      final pollingService = context.read<OrderPollingService>();
      // Esperar un momento para que el backend procese
      await Future.delayed(const Duration(milliseconds: 500));
      // Reiniciar polling para forzar verificación inmediata
      pollingService.stopPolling();
      pollingService.startPolling(driverId, token);
    } else if (mounted && orderProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectOrder(
    OrderProvider orderProvider,
    AuthProvider authProvider,
  ) async {
    final token = authProvider.token;
    final driverId = authProvider.driver?.id;
    if (token == null || driverId == null) return;
    await orderProvider.rejectOrder(driverId, token);
  }
}
