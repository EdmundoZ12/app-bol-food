import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme/app_theme.dart';

class HistoryOrderCard extends StatelessWidget {
  final String date;
  final String orderNumber;
  final String address;
  final String totalAmount;
  final String earnings;

  const HistoryOrderCard({
    super.key,
    required this.date,
    required this.orderNumber,
    required this.address,
    required this.totalAmount,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: GoogleFonts.montserratAlternates(
              fontSize: 14,
              color: const Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'ORDEN #$orderNumber',
              style: GoogleFonts.montserratAlternates(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 18, color: Color(0xFF333333)),
              const SizedBox(width: 4),
              Text(
                address,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 14,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), // Light yellow
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cobrado:',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$totalAmount Bs.',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryYellow,
                  ),
                ),
                Text(
                  '$earnings Bs.',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
