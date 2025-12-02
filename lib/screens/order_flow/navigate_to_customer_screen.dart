import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../models/order/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order/order_service.dart';
import '../../services/order/order_polling_service.dart';
import '../../widgets/navigation_map_widget.dart';

class NavigateToCustomerScreen extends StatefulWidget {
  final Order order;

  const NavigateToCustomerScreen({super.key, required this.order});

  @override
  State<NavigateToCustomerScreen> createState() =>
      _NavigateToCustomerScreenState();
}

class _NavigateToCustomerScreenState extends State<NavigateToCustomerScreen> {
  final OrderService _orderService = OrderService();
  @override
  void initState() {
    super.initState();
    _isAtDoor = widget.order.status == OrderStatus.atPlace;
  }

  bool _isLoading = false;
  late bool _isAtDoor;

  Future<void> _handleButtonPress() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!_isAtDoor) {
        // Marcar como "en la puerta"
        await _orderService.atCustomerDoor(
          widget.order.id,
          authProvider.driver!.id,
          authProvider.token!,
        );

        setState(() {
          _isAtDoor = true;
        });
      } else {
        // Confirmar entrega
        await _orderService.confirmDelivery(
          widget.order.id,
          authProvider.driver!.id,
          authProvider.token!,
        );

        if (mounted) {
          // Limpiar el pedido activo del polling para detener la navegación automática
          context.read<OrderPollingService>().clearActiveOrder();
          context.go('/order/success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  void _showDeliveredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: primaryYellow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Pedido Entregado!',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlack,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Has completado la entrega exitosamente',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserratAlternates(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                context.go('/home');
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Volver al inicio',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.order.totalAmount;
    final isCash = widget.order.paymentMethod == 'CASH';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'BolFood',
              style: GoogleFonts.montserratAlternates(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryYellow,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: Text(
              _isAtDoor ? 'Entrega el pedido' : 'Dirígete al cliente',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Customer Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Información del cliente',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Nombre',
                  value: widget.order.user?.name ?? 'Cliente',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Dirección',
                  value: widget.order.deliveryAddress ?? 'No especificada',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  value: widget.order.phone ?? 'No especificado',
                ),
                if (isCash) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cobrar en efectivo',
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${totalAmount.toStringAsFixed(2)} Bs.',
                                style: GoogleFonts.montserratAlternates(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Map Navigation
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: NavigationMapWidget(
                destination: widget.order.latitude != null && widget.order.longitude != null
                    ? LatLng(widget.order.latitude!, widget.order.longitude!)
                    : const LatLng(-17.783327, -63.182140), // Fallback coordinates
                destinationName: widget.order.user?.name ?? 'Cliente',
                onArrived: () {
                  // Auto-habilitar botón cuando esté cerca (50m)
                  if (!_isAtDoor && mounted) {
                    setState(() {
                      _isAtDoor = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Has llegado al destino'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: _isLoading ? null : _handleButtonPress,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: _isAtDoor ? Colors.green : primaryYellow,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isAtDoor ? 'Confirmar entrega' : 'Estoy en la puerta',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isAtDoor ? Colors.white : Colors.black,
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryBlack),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserratAlternates(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Inicio', true),
          _buildNavItem(Icons.local_shipping, 'Entregas', false),
          _buildNavItem(Icons.person, 'Perfil', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primaryBlack : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.montserratAlternates(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? primaryBlack : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
