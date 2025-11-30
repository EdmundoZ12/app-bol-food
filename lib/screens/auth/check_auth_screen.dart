import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../notifications/bloc/notifications_bloc.dart';
import '../../providers/auth_provider.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    // Pedir permisos de notificaciones
    _requestNotificationPermissions();
  }

  void _requestNotificationPermissions() {
    final notificationsBloc = context.read<NotificationsBloc>();
    notificationsBloc.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.authStatus == AuthStatus.authenticated) {
              context.go('/home');
            } else if (authProvider.authStatus == AuthStatus.notAuthenticated) {
              context.go('/login');
            }
          });

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFE8A838)),
                SizedBox(height: 20),
                Text('Cargando...', style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}
