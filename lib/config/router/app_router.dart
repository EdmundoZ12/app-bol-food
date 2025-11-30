import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
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
  ],
);
