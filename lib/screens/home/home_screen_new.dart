import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../services/order_service.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../orders/active_order_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late OrderService _orderService;
  List<Order> _activeOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    final dio = Dio(BaseOptions(
      baseURL: AppConstants.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));
    _orderService = OrderService(dio);
    
    _loadActiveOrders();
  }

  Future<void> _loadActiveOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.driver == null) return;

    setState(() => _isLoading = true);

    try {
      final orders = await _orderService.getDriverOrders(authProvider.driver!.id);
      setState(() {
        _activeOrders = orders.where((order) => 
          order.status != 'DELIVERED' && order.status != 'CANCELLED'
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error cargando pedidos: $e');
    }
  }

  Future<void> _changeStatus(String newStatus) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.driver == null) return;

    try {
      await authProvider.updateDriverStatus(newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a: ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cambiando estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Disponible';
      case 'BUSY':
        return 'Ocupado';
      case 'OFFLINE':
        return 'Desconectado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'BUSY':
        return Colors.orange;
      case 'OFFLINE':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final trackingProvider = Provider.of<TrackingProvider>(context);
    final driver = authProvider.driver;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bol Food Driver'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadActiveOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información del driver
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.indigo,
                        child: Text(
                          driver?.name[0].toUpperCase() ?? 'D',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${driver?.name ?? ''} ${driver?.lastname ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        driver?.vehicle ?? 'Sin vehículo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Estado y tracking
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(driver?.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(driver?.status ?? ''),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: driver?.status == 'AVAILABLE'
                                  ? null
                                  : () => _changeStatus('AVAILABLE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Disponible'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: driver?.status == 'OFFLINE'
                                  ? null
                                  : () => _changeStatus('OFFLINE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Desconectado'),
                            ),
                          ),
                        ],
                      ),
                      if (trackingProvider.isTracking) ...[
                        const Divider(),
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            const Text('Tracking activo'),
                            const Spacer(),
                            if (trackingProvider.currentPosition != null)
                              Text(
                                '${trackingProvider.currentPosition!.latitude.toStringAsFixed(4)}, ${trackingProvider.currentPosition!.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Pedidos activos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pedidos Activos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadActiveOrders,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_activeOrders.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes pedidos activos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cambia tu estado a "Disponible" para recibir pedidos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._activeOrders.map((order) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getOrderStatusColor(order.status),
                      child: const Icon(Icons.delivery_dining, color: Colors.white),
                    ),
                    title: Text(
                      order.deliveryAddress ?? 'Sin dirección',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_getOrderStatusText(order.status)} • Bs. ${order.driverEarnings?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ActiveOrderScreen(order: order),
                        ),
                      ).then((_) => _loadActiveOrders());
                    },
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'ASSIGNED':
        return Colors.blue;
      case 'PICKING_UP':
        return Colors.orange;
      case 'PICKED_UP':
        return Colors.purple;
      case 'IN_TRANSIT':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(String status) {
    switch (status) {
      case 'ASSIGNED':
        return 'Asignado';
      case 'PICKING_UP':
        return 'Yendo al restaurante';
      case 'PICKED_UP':
        return 'Recogido';
      case 'IN_TRANSIT':
        return 'En camino';
      default:
        return status;
    }
  }
}
