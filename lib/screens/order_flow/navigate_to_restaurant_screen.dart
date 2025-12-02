import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../models/order/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order/order_service.dart';
import '../../widgets/navigation_map_widget.dart';

class NavigateToRestaurantScreen extends StatefulWidget {
  final Order order;

  const NavigateToRestaurantScreen({super.key, required this.order});

  @override
  State<NavigateToRestaurantScreen> createState() =>
      _NavigateToRestaurantScreenState();
}

class _NavigateToRestaurantScreenState
    extends State<NavigateToRestaurantScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  Future<void> _arrivedAtRestaurant() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await _orderService.arrivedAtRestaurant(
        widget.order.id,
        authProvider.driver!.id,
        authProvider.token!,
      );

      if (mounted) {
        context.push('/order/confirm-pickup', extra: widget.order);
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

  @override
  Widget build(BuildContext context) {
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
              'Dirígete al restaurant',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Order Info Card
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
                    const Icon(Icons.fastfood, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Orden #${widget.order.id.substring(0, 8).toUpperCase()}',
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
                  icon: Icons.store,
                  label: 'Nombre',
                  value: 'BolFood Restaurant', // Mock data
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Dirección',
                  value: 'Av Cañoto #4571', // Mock data
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  value: '+591 725 854 12', // Mock data
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Items a recoger',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.order.orderItems.length} items',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 14,
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

          // Map Navigation
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: NavigationMapWidget(
                destination: const LatLng(-17.783327, -63.182140), // Mock: Coordenadas de Santa Cruz
                destinationName: 'BolFood Restaurant',
                onArrived: () {
                  // Opcional: Auto-navegar cuando llegue
                  // _arrivedAtRestaurant();
                },
              ),
            ),
          ),

          // Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: _isLoading ? null : _arrivedAtRestaurant,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: primaryYellow,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'He llegado al restaurant',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
