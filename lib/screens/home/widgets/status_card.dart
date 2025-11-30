import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_theme.dart';

class StatusCard extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onStatusChanged;

  const StatusCard({
    super.key,
    required this.isOnline,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? primaryYellow : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOnline ? 'En línea' : 'Desconectado',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlack,
                ),
              ),
              Text(
                isOnline ? 'Recibiendo pedidos' : 'Fuera de línea',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Switch(
            value: isOnline,
            onChanged: onStatusChanged,
            activeColor: primaryYellow,
            activeTrackColor: primaryYellow.withOpacity(0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
