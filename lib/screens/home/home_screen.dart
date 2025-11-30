import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_navbar.dart';
import 'widgets/stat_card.dart';
import 'widgets/status_card.dart';
import 'widgets/waiting_orders_card.dart';
import 'widgets/offline_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final driver = authProvider.driver;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.delivery_dining, color: primaryYellow, size: 28);
              },
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bol',
                    style: GoogleFonts.montserratAlternates(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: 'Food',
                    style: GoogleFonts.montserratAlternates(
                      color: primaryYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            // Swipe Left -> Go to History
            context.go('/history');
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                'Bienvenido ${driver?.name ?? ""}',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Status Card
              StatusCard(
                isOnline: _isOnline,
                onStatusChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                  // TODO: Call API to update status
                },
              ),
              const SizedBox(height: 30),

              // Resumen Card
              Container(
                padding: const EdgeInsets.all(20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resumen de hoy',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('d MMM. yyyy').format(DateTime.now()),
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: const [
                        StatCard(
                          icon: Icons.check_circle_outline,
                          title: 'Entregas',
                          value: '12',
                        ),
                        StatCard(
                          icon: Icons.attach_money,
                          title: 'Ganancias',
                          value: 'Bs. 87.20',
                        ),
                        StatCard(
                          icon: Icons.access_time,
                          title: 'Horas',
                          value: '5.5h',
                        ),
                        StatCard(
                          icon: Icons.trending_up,
                          title: 'Aceptación',
                          value: '90%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Waiting Orders or Offline Card
              if (_isOnline) 
                const WaitingOrdersCard()
              else
                const OfflineCard(),
              // Extra space for bottom nav
              const SizedBox(height: 20),
            ],
          ),
        ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              // Already here
            } else if (index == 1) {
              context.go('/history');
            } else if (index == 2) {
              context.go('/profile');
            }
          });
        },
      ),
    );
  }
}
