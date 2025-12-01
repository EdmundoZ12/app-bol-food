import 'package:bol_food_app/screens/orders/order_delivered_screen.dart';
import 'package:go_router/go_router.dart';

import '../../screens/screens.dart';

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
  ],
);
