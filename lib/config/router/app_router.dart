import 'package:bol_food_app/screens/orders/order_delivered_screen.dart';
import 'package:bol_food_app/screens/order/delivery_success_screen.dart';
import 'package:go_router/go_router.dart';

import '../../screens/screens.dart';
import '../../models/order/order.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash Screen (inicial)
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // Check Auth
    GoRoute(
      path: '/check-auth',
      builder: (context, state) => const CheckAuthScreen(),
    ),

    // Auth Routes
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Home
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Active Order
    GoRoute(
      path: '/active-order',
      builder: (context, state) => const ActiveOrderScreen(),
    ),
    GoRoute(
      path: '/order-delivered',
      builder: (context, state) => const OrderDeliveredScreen(),
    ),

    // Order Flow Routes
    GoRoute(
      path: '/order/new',
      builder: (context, state) {
        final order = state.extra as Order;
        return NewOrderScreen(order: order);
      },
    ),
    GoRoute(
      path: '/order/navigate-restaurant',
      builder: (context, state) {
        final order = state.extra as Order;
        return NavigateToRestaurantScreen(order: order);
      },
    ),
    GoRoute(
      path: '/order/confirm-pickup',
      builder: (context, state) {
        final order = state.extra as Order;
        return ConfirmPickupScreen(order: order);
      },
    ),
    GoRoute(
      path: '/order/navigate-customer',
      builder: (context, state) {
        final order = state.extra as Order;
        return NavigateToCustomerScreen(order: order);
      },
    ),
    GoRoute(
      path: '/order/success',
      builder: (context, state) => const DeliverySuccessScreen(),
    ),
  ],
);
