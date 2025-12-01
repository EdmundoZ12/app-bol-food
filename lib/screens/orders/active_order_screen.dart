import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../services/order_service.dart';
import '../../config/constants.dart';
import 'package:dio/dio.dart';

class ActiveOrderScreen extends StatefulWidget {
  final Order order;

  const ActiveOrderScreen({super.key, required this.order});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  late Order _currentOrder;
  bool _isLoading = false;
  late OrderService _orderService;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    _orderService = OrderService(dio);

    // Iniciar tracking si el pedido está asignado
    if (_currentOrder.status == 'ASSIGNED' || 
        _currentOrder.status == 'PICKING_UP' ||
        _currentOrder.status == 'PICKED_UP' ||
        _currentOrder.status == 'IN_TRANSIT') {
      _startTracking();
    }
  }

  void _startTracking() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
    
    if (authProvider.driver != null) {
      trackingProvider.startTracking(authProvider.driver!.id);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);

    try {
      final updatedOrder = await _orderService.updateOrderStatus(
        _currentOrder.id,
        newStatus,
      );

      setState(() {
        _currentOrder = updatedOrder;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a: ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error actualizando estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsDelivered() async {
    setState(() => _isLoading = true);

    try {
      final updatedOrder = await _orderService.markAsDelivered(_currentOrder.id);

      setState(() {
        _currentOrder = updatedOrder;
        _isLoading = false;
      });

      // Detener tracking
      final trackingProvider = Provider.of<TrackingProvider>(context, listen: false);
      await trackingProvider.stopTracking();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Pedido entregado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Volver a la pantalla anterior después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marcando como entregado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ASSIGNED':
        return 'Asignado';
      case 'PICKING_UP':
        return 'Yendo al restaurante';
      case 'PICKED_UP':
        return 'Pedido recogido';
      case 'IN_TRANSIT':
        return 'En camino al cliente';
      case 'DELIVERED':
        return 'Entregado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ASSIGNED':
        return Colors.blue;
      case 'PICKING_UP':
        return Colors.orange;
      case 'PICKED_UP':
        return Colors.purple;
      case 'IN_TRANSIT':
        return Colors.indigo;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButton() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_currentOrder.status) {
      case 'ASSIGNED':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus('PICKING_UP'),
          icon: const Icon(Icons.restaurant),
          label: const Text('Ir al Restaurante'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      case 'PICKING_UP':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus('PICKED_UP'),
          icon: const Icon(Icons.check_circle),
          label: const Text('Marcar como Recogido'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      case 'PICKED_UP':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus('IN_TRANSIT'),
          icon: const Icon(Icons.delivery_dining),
          label: const Text('Ir al Cliente'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      case 'IN_TRANSIT':
        return ElevatedButton.icon(
          onPressed: _markAsDelivered,
          icon: const Icon(Icons.done_all),
          label: const Text('Marcar como Entregado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = Provider.of<TrackingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido Activo'),
        backgroundColor: _getStatusColor(_currentOrder.status),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado actual
            Card(
              color: _getStatusColor(_currentOrder.status).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: _getStatusColor(_currentOrder.status),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusText(_currentOrder.status),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(_currentOrder.status),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de ganancia y distancia
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.attach_money, size: 32, color: Colors.green),
                          const SizedBox(height: 8),
                          Text(
                            'Bs. ${_currentOrder.driverEarnings?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Ganancia'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.route, size: 32, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentOrder.distanceKm?.toStringAsFixed(2) ?? '0.00'} km',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Distancia'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dirección de entrega
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Dirección de Entrega'),
                subtitle: Text(_currentOrder.deliveryAddress ?? 'No especificada'),
              ),
            ),

            // Teléfono
            if (_currentOrder.phone != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text('Teléfono'),
                  subtitle: Text(_currentOrder.phone!),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () {
                      // Aquí puedes agregar funcionalidad para llamar
                    },
                  ),
                ),
              ),

            // Notas
            if (_currentOrder.notes != null && _currentOrder.notes!.isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.note, color: Colors.orange),
                  title: const Text('Notas'),
                  subtitle: Text(_currentOrder.notes!),
                ),
              ),

            const SizedBox(height: 16),

            // Items del pedido
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ..._currentOrder.orderItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.productName ?? 'Producto'}',
                            ),
                          ),
                          Text(
                            'Bs. ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bs. ${_currentOrder.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tracking status
            if (trackingProvider.isTracking)
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('Tracking activo'),
                      const Spacer(),
                      if (trackingProvider.currentPosition != null)
                        Text(
                          '${trackingProvider.currentPosition!.latitude.toStringAsFixed(6)}, ${trackingProvider.currentPosition!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Botón de acción
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // No detener tracking aquí, solo cuando se entrega el pedido
    super.dispose();
  }
}
