import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_theme.dart';

class WaitingOrdersCard extends StatelessWidget {
  const WaitingOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: primaryYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.room_service,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Esperando pedidos...',
            style: GoogleFonts.montserratAlternates(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los pedidos aparecerán automáticamente',
            style: GoogleFonts.montserratAlternates(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
