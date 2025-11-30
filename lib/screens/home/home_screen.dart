import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final driver = authProvider.driver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlack,
        title: Text(
          'Bol Food Driver',
          style: GoogleFonts.montserratAlternates(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: primaryYellow,
                child: Text(
                  driver?.name.substring(0, 1).toUpperCase() ?? 'D',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: primaryBlack,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bienvenida
              Text(
                '¡Bienvenido!',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Nombre completo
              Text(
                driver?.fullName ?? 'Driver',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                driver?.email ?? '',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Estado del driver
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(driver?.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(driver?.status),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(driver?.status),
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Card vehículo
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.motorcycle,
                        size: 40,
                        color: primaryYellow,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehículo',
                            style: GoogleFonts.montserratAlternates(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            driver?.vehicle ?? 'No registrado',
                            style: GoogleFonts.montserratAlternates(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Card teléfono
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 40, color: primaryYellow),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teléfono',
                            style: GoogleFonts.montserratAlternates(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            driver?.phone ?? 'No registrado',
                            style: GoogleFonts.montserratAlternates(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'BUSY':
        return Colors.orange;
      case 'OFFLINE':
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return Icons.check_circle;
      case 'BUSY':
        return Icons.delivery_dining;
      case 'OFFLINE':
      default:
        return Icons.power_settings_new;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Disponible';
      case 'BUSY':
        return 'En entrega';
      case 'OFFLINE':
      default:
        return 'Desconectado';
    }
  }
}
