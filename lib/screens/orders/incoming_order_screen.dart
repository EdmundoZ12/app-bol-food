import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../config/constants.dart';
import 'active_order_screen.dart';

class IncomingOrderScreen extends StatefulWidget {
  final Order order;

  const IncomingOrderScreen({super.key, required this.order});

  @override
  State<IncomingOrderScreen> createState() => _IncomingOrderScreenState();
}

class _IncomingOrderScreenState extends State<IncomingOrderScreen> {
  bool _isLoading = false;
  late OrderService _orderService;

  @override
  void initState() {
    super.initState();
    
    final dio = Dio(BaseOptions(
      baseURL: AppConstants.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));
    _orderService = OrderService(dio);
  }

  Future<void> _acceptOrder() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.driver == null) return;

    setState(() => _isLoading = true);

    try {
      final acceptedOrder = await _orderService.acceptOrder(
        widget.order.id,
        authProvider.driver!.id,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ActiveOrderScreen(order: acceptedOrder),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error aceptando pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectOrder() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.driver == null) return;

    setState(() => _isLoading = true);

    try {
      await _orderService.rejectOrder(
        widget.order.id,
        authProvider.driver!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido rechazado'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rechazando pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Pedido'),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Alerta de nuevo pedido
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.notifications_active, size: 64, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          '¡Nuevo Pedido Disponible!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ganancia y distancia
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(Icons.attach_money, size: 40, color: Colors.green),
                                const SizedBox(height: 8),
                                Text(
                                  'Bs. ${widget.order.driverEarnings?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text(
                                  'Ganancia',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(Icons.route, size: 40, color: Colors.blue),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.order.distanceKm?.toStringAsFixed(2) ?? '0.00'} km',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'Distancia',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Información del pedido
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalles del Pedido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.red),
                            title: const Text('Dirección'),
                            subtitle: Text(widget.order.deliveryAddress ?? 'No especificada'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (widget.order.phone != null)
                            ListTile(
                              leading: const Icon(Icons.phone, color: Colors.green),
                              title: const Text('Teléfono'),
                              subtitle: Text(widget.order.phone!),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ListTile(
                            leading: const Icon(Icons.payment, color: Colors.orange),
                            title: const Text('Método de Pago'),
                            subtitle: Text(widget.order.paymentMethod ?? 'No especificado'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (widget.order.notes != null && widget.order.notes!.isNotEmpty)
                            ListTile(
                              leading: const Icon(Icons.note, color: Colors.blue),
                              title: const Text('Notas'),
                              subtitle: Text(widget.order.notes!),
                              contentPadding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Productos
                  Card(
                    elevation: 2,
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
                          ...widget.order.orderItems.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.productName ?? 'Producto'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Text(
                                  'Bs. ${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Bs. ${widget.order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
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

                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _rejectOrder,
                          icon: const Icon(Icons.close),
                          label: const Text('Rechazar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _acceptOrder,
                          icon: const Icon(Icons.check),
                          label: const Text('Aceptar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
