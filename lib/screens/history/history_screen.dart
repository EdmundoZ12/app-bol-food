import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../widgets/custom_navbar.dart';
import 'widgets/history_filter_button.dart';
import 'widgets/history_order_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 1;
  String _selectedFilter = 'Hoy';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.driver != null) {
        context.read<OrderProvider>().getDriverOrders(authProvider.driver!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
          if (details.primaryVelocity! > 0) {
            // Swipe Right -> Go to Home
            context.go('/home');
          }
        },
        child: Column(
          children: [
          const SizedBox(height: 24),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Historial de entregas',
                style: GoogleFonts.montserratAlternates(
                  fontSize: 32, // Same size as Welcome title
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                HistoryFilterButton(
                  label: 'Hoy',
                  isSelected: _selectedFilter == 'Hoy',
                  onTap: () => setState(() => _selectedFilter = 'Hoy'),
                ),
                const SizedBox(width: 12),
                HistoryFilterButton(
                  label: 'Esta semana',
                  isSelected: _selectedFilter == 'Esta semana',
                  onTap: () => setState(() => _selectedFilter = 'Esta semana'),
                ),
                const SizedBox(width: 12),
                HistoryFilterButton(
                  label: 'Todos',
                  isSelected: _selectedFilter == 'Todos',
                  onTap: () => setState(() => _selectedFilter = 'Todos'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // List
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (orderProvider.error != null) {
                  return Center(child: Text('Error: ${orderProvider.error}'));
                }

                List<Order> ordersToShow;
                switch (_selectedFilter) {
                  case 'Hoy':
                    ordersToShow = orderProvider.todayOrders;
                    break;
                  case 'Esta semana':
                    ordersToShow = orderProvider.weekOrders;
                    break;
                  case 'Todos':
                  default:
                    ordersToShow = orderProvider.orders;
                    break;
                }

                if (ordersToShow.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay entregas registradas',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: ordersToShow.length,
                  itemBuilder: (context, index) {
                    final order = ordersToShow[index];
                    return HistoryOrderCard(
                      date: DateFormat('d MMM. yyyy - HH:mm').format(order.createdAt),
                      orderNumber: order.id.substring(0, 8).toUpperCase(),
                      address: order.deliveryAddress ?? 'Sin dirección',
                      totalAmount: order.totalAmount.toStringAsFixed(2),
                      earnings: (order.driverEarnings ?? 0).toStringAsFixed(2),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              context.go('/home');
            } else if (index == 1) {
              // Already here
            } else if (index == 2) {
              context.go('/profile');
            }
          });
        },
      ),
    );
  }
}
