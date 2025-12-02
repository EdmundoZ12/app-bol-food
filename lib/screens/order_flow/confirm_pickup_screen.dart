import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../models/order/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/order/order_service.dart';

class ConfirmPickupScreen extends StatefulWidget {
  final Order order;

  const ConfirmPickupScreen({super.key, required this.order});

  @override
  State<ConfirmPickupScreen> createState() => _ConfirmPickupScreenState();
}

class _ConfirmPickupScreenState extends State<ConfirmPickupScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  Future<void> _confirmPickup() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await _orderService.confirmPickup(
        widget.order.id,
        authProvider.driver!.id,
        authProvider.token!,
      );

      if (mounted) {
        context.push('/order/navigate-customer', extra: widget.order);
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
              'Confirma los items',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Order Header
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
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
                  ),

                  // Items List
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Items del pedido',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryBlack,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Order Items
                        ...widget.order.orderItems.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mock Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style:
                                              GoogleFonts.montserratAlternates(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: primaryBlack,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'x${item.quantity}',
                                          style:
                                              GoogleFonts.montserratAlternates(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.subTotal.toStringAsFixed(2)} Bs.',
                                    style: GoogleFonts.montserratAlternates(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlack,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Total
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryYellow.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total del pedido',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryBlack,
                              ),
                            ),
                            Text(
                              '${totalAmount.toStringAsFixed(2)} Bs.',
                              style: GoogleFonts.montserratAlternates(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlack,
                              ),
                            ),
                          ],
                        ),
                        if (isCash) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Deberás cobrar ${totalAmount.toStringAsFixed(2)} Bs. al cliente.',
                                    style: GoogleFonts.montserratAlternates(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: _isLoading ? null : _confirmPickup,
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
                      'Confirmar Recogida',
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
