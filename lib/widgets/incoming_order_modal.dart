import 'dart:async';
import 'package:bol_food_app/models/order/order.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme/app_theme.dart';

class IncomingOrderModal extends StatefulWidget {
  final Order order;
  final String? address;
  final double? distanceKm;
  final int? estimatedMinutes;
  final String? paymentMethod;
  final double? earnings;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final int timeoutSeconds;

  const IncomingOrderModal({
    super.key,
    required this.order,
    this.address,
    this.distanceKm,
    this.estimatedMinutes,
    this.paymentMethod,
    this.earnings,
    required this.onAccept,
    required this.onReject,
    this.timeoutSeconds = 30,
  });

  @override
  State<IncomingOrderModal> createState() => _IncomingOrderModalState();
}

class _IncomingOrderModalState extends State<IncomingOrderModal> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeoutSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        widget.onReject();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header amarillo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delivery_dining, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  'Nuevo Pedido',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dirección
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Dirección',
                  widget.address ??
                      widget.order.deliveryAddress ??
                      'No especificada',
                ),
                const SizedBox(height: 12),

                // Distancia
                _buildInfoRow(
                  Icons.route,
                  'Distancia',
                  '${(widget.distanceKm ?? widget.order.deliveryDistance ?? 0).toStringAsFixed(1)} km',
                ),
                const SizedBox(height: 12),

                // Tiempo estimado
                _buildInfoRow(
                  Icons.access_time,
                  'Tiempo estimado',
                  '${widget.estimatedMinutes ?? 25} min',
                ),
                const SizedBox(height: 12),

                // Método de pago
                _buildInfoRow(
                  Icons.payment,
                  'Método de pago',
                  widget.paymentMethod ?? widget.order.paymentMethodText,
                ),
                const SizedBox(height: 16),

                // Ganancia estimada
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ganancia estimada',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(widget.earnings ?? widget.order.driverEarnings ?? 0).toStringAsFixed(2)} Bs.',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Timer circular y botones
                Row(
                  children: [
                    // Botón Rechazar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onReject,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Rechazar',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Timer circular
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: _remainingSeconds / widget.timeoutSeconds,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _remainingSeconds <= 10
                                  ? Colors.red
                                  : primaryYellow,
                            ),
                            strokeWidth: 4,
                          ),
                        ),
                        Text(
                          '$_remainingSeconds',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _remainingSeconds <= 10
                                ? Colors.red
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Botón Aceptar
                    Expanded(
                      child: FilledButton(
                        onPressed: widget.onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryBlack,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Aceptar Pedido',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryYellow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserratAlternates(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
