import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../models/order/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order/order_service.dart';

class NewOrderScreen extends StatefulWidget {
  final Order order;

  const NewOrderScreen({super.key, required this.order});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  Future<void> _acceptOrder() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await _orderService.acceptOrder(
        widget.order.id,
        authProvider.driver!.id,
        authProvider.token!,
      );

      if (mounted) {
        context.push('/order/navigate-restaurant', extra: widget.order);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aceptar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectOrder() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await _orderService.rejectOrder(
        widget.order.id,
        authProvider.driver!.id,
        authProvider.token!,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.fastfood,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nuevo Pedido',
                    style: GoogleFonts.montserratAlternates(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dirección
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Dirección',
                      content: widget.order.deliveryAddress ?? 'No especificada',
                    ),
                    const SizedBox(height: 16),

                    // Distancia
                    _buildInfoCard(
                      icon: Icons.route,
                      title: 'Distancia',
                      content: widget.order.deliveryDistance != null
                          ? '${widget.order.deliveryDistance!.toStringAsFixed(1)} km'
                          : '5.7 km', // Mock data
                    ),
                    const SizedBox(height: 16),

                    // Tiempo estimado
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Tiempo estimado',
                      content: '25 min', // Mock data
                    ),
                    const SizedBox(height: 16),

                    // Método de pago
                    _buildInfoCard(
                      icon: Icons.payment,
                      title: 'Método de pago',
                      content: widget.order.paymentMethod == 'CASH'
                          ? 'Efectivo'
                          : 'QR',
                    ),
                    const SizedBox(height: 24),

                    // Ganancia estimada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryYellow.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ganancia estimada',
                            style: GoogleFonts.montserratAlternates(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryBlack,
                            ),
                          ),
                          Text(
                            '${widget.order.driverEarnings?.toStringAsFixed(2) ?? '10.50'} Bs.',
                            style: GoogleFonts.montserratAlternates(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _rejectOrder,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: primaryBlack, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Rechazar',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _acceptOrder,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Aceptar Pedido',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.montserratAlternates(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
        ],
      ),
    );
  }
}
