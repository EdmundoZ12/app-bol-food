import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class OrderDeliveredScreen extends StatefulWidget {
  const OrderDeliveredScreen({super.key});

  @override
  State<OrderDeliveredScreen> createState() => _OrderDeliveredScreenState();
}

class _OrderDeliveredScreenState extends State<OrderDeliveredScreen> {
  @override
  void initState() {
    super.initState();
    // Redirigir al home después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0, onTap: (index) {}),
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
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedido Entregado!',
            style: GoogleFonts.montserratAlternates(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          // Card de éxito
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de éxito
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryYellow.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delivery_dining,
                        color: primaryYellow,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Texto de éxito
                    Text(
                      '¡Pedido Entregado!',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Excelente trabajo. Redirigiendo...',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Loading indicator
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
