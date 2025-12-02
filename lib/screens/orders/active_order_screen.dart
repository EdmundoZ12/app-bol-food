import 'package:bol_food_app/models/order/order.dart';
import 'package:bol_food_app/services/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/order_item_card.dart';

class ActiveOrderScreen extends StatefulWidget {
  const ActiveOrderScreen({super.key});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  bool _isLoading = false;
  bool _isAtDoor = false; // Sub-estado para IN_TRANSIT
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (hasPermission) {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _driverLocation = LatLng(position.latitude, position.longitude);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.currentOrder;

    if (order == null) {
      return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: primaryYellow),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContentByStatus(order, orderProvider)),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/home');
        },
      ),
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

  Widget _buildContentByStatus(Order order, OrderProvider orderProvider) {
    switch (order.status) {
      case OrderStatus.accepted:
        // Estado inicial: Mostrar "Voy al restaurante"
        return _buildAcceptedView(order, orderProvider);
      case OrderStatus.pickingUp:
        // En camino al restaurante: Mostrar "He llegado"
        return _buildGoToRestaurantView(order, orderProvider);
      case OrderStatus.pickedUp:
        return _buildConfirmItemsView(order, orderProvider);
      case OrderStatus.inTransit:
        if (_isAtDoor) {
          return _buildConfirmDeliveryView(order, orderProvider);
        } else {
          return _buildDeliveringView(order, orderProvider);
        }
      default:
        return _buildAcceptedView(order, orderProvider);
    }
  }

  // ============================================
  // ESTADO: ACCEPTED
  // Pantalla: "Pedido aceptado - Ir al restaurante"
  // ============================================
  Widget _buildAcceptedView(Order order, OrderProvider orderProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Pedido Aceptado!',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order ID Badge
            _buildOrderBadge(order),
            const SizedBox(height: 16),

            // Info del restaurante
            _buildRestaurantInfoCard(order),
            const SizedBox(height: 16),

            // Mapa
            _buildMap(
              destinationLat: AppConstants.restaurantLatitude,
              destinationLng: AppConstants.restaurantLongitude,
            ),
            const SizedBox(height: 20),

            // Botón: Voy al restaurante
            _buildActionButton(
              'Voy al restaurante',
              () => _markPickingUp(orderProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ESTADO: PICKING_UP
  // Pantalla: "Dirígete al restaurant"
  // ============================================
  Widget _buildGoToRestaurantView(Order order, OrderProvider orderProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirígete al restaurant',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order ID Badge
            _buildOrderBadge(order),
            const SizedBox(height: 16),

            // Info del restaurante
            _buildRestaurantInfoCard(order),
            const SizedBox(height: 16),

            // Mapa
            _buildMap(
              destinationLat: AppConstants.restaurantLatitude,
              destinationLng: AppConstants.restaurantLongitude,
            ),
            const SizedBox(height: 20),

            // Botón
            _buildActionButton(
              'He llegado al restaurant',
              () => _markPickedUp(orderProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfoCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.store, 'Nombre', AppConstants.restaurantName),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Dirección',
            AppConstants.restaurantAddress,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.phone_outlined,
            'Teléfono',
            AppConstants.restaurantPhone,
          ),
          const Divider(height: 20),
          // Items a recoger
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  color: primaryYellow,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items a recoger',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${order.itemsCount} items',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  // ============================================
  // ESTADO: PICKED_UP
  // Pantalla: "Confirma los items"
  // ============================================
  Widget _buildConfirmItemsView(Order order, OrderProvider orderProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirma los items',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order ID Badge
            _buildOrderBadge(order),
            const SizedBox(height: 16),

            // Título de sección
            Row(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  color: primaryYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Items del pedido',
                  style: GoogleFonts.montserratAlternates(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de items
            ...order.orderItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OrderItemCard(item: item),
              ),
            ),
            const SizedBox(height: 16),

            // Total del pedido
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total del pedido',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} Bs.',
                        style: GoogleFonts.montserratAlternates(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: primaryYellow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Deberás cobrar ${order.totalToCobrar.toStringAsFixed(2)} Bs. al cliente.',
                          style: GoogleFonts.montserratAlternates(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón
            _buildActionButton(
              'Confirmar Recogida',
              () => _markInTransit(orderProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ESTADO: IN_TRANSIT (con mapa)
  // Pantalla: "Entregando Pedido"
  // ============================================
  Widget _buildDeliveringView(Order order, OrderProvider orderProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entregando Pedido',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order ID Badge
            _buildOrderBadge(order),
            const SizedBox(height: 16),

            // Dirección del cliente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _buildInfoRow(
                Icons.location_on_outlined,
                'Dirección',
                order.deliveryAddress ?? 'Sin dirección',
              ),
            ),
            const SizedBox(height: 16),

            // Mapa con ruta al cliente
            _buildMap(
              destinationLat: order.latitude ?? 0,
              destinationLng: order.longitude ?? 0,
            ),
            const SizedBox(height: 16),

            // Nota del cliente
            if (order.notes != null && order.notes!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nota del cliente',
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.notes!,
                      style: GoogleFonts.montserratAlternates(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Botón
            _buildActionButton('Estoy en la puerta', () {
              setState(() {
                _isAtDoor = true;
              });
            }),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ESTADO: IN_TRANSIT (at_door - sin mapa)
  // Pantalla: "Confirmar entrega"
  // ============================================
  Widget _buildConfirmDeliveryView(Order order, OrderProvider orderProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entregando Pedido',
              style: GoogleFonts.montserratAlternates(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order ID Badge (usando "Nuevo Pedido" como en el diseño)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delivery_dining,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nuevo Pedido',
                    style: GoogleFonts.montserratAlternates(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info del cliente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Dirección',
                    order.deliveryAddress ?? 'Sin dirección',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.person_outline,
                    'Nombre',
                    order.user?.displayName ?? 'Cliente',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Teléfono',
                    order.phone ?? 'Sin teléfono',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lista de items
            ...order.orderItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OrderItemCard(item: item),
              ),
            ),
            const SizedBox(height: 16),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total del pedido',
                    style: GoogleFonts.montserratAlternates(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${order.totalToCobrar.toStringAsFixed(2)} Bs.',
                    style: GoogleFonts.montserratAlternates(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón
            _buildActionButton(
              'Confirmar entrega',
              () => _markDelivered(orderProvider),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // WIDGETS COMUNES
  // ============================================
  Widget _buildOrderBadge(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delivery_dining, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Text(
            'Orden ${order.shortId}',
            style: GoogleFonts.montserratAlternates(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryYellow, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap({
    required double destinationLat,
    required double destinationLng,
  }) {
    final destination = LatLng(destinationLat, destinationLng);
    final driverPos = _driverLocation ?? destination;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: destination, zoom: 14),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
          if (_driverLocation != null)
            Marker(
              markerId: const MarkerId('driver'),
              position: driverPos,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
        },
        polylines: _driverLocation != null
            ? {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [driverPos, destination],
                  color: Colors.blue,
                  width: 4,
                ),
              }
            : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.montserratAlternates(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ============================================
  // ACCIONES
  // ============================================
  Future<void> _markPickingUp(OrderProvider orderProvider) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _isLoading = true);
    await orderProvider.markPickingUp(token);
    setState(() => _isLoading = false);
  }

  Future<void> _markPickedUp(OrderProvider orderProvider) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _isLoading = true);
    await orderProvider.markPickedUp(token);
    setState(() => _isLoading = false);
  }

  Future<void> _markInTransit(OrderProvider orderProvider) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _isLoading = true);
    await orderProvider.markInTransit(token);
    setState(() => _isLoading = false);
  }

  Future<void> _markDelivered(OrderProvider orderProvider) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _isLoading = true);
    final success = await orderProvider.markDelivered(token);
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/order-delivered');
    }
  }
}
