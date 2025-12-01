import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/config.dart';
import 'config/router/app_router.dart';
import 'notifications/bloc/notifications_bloc.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  await NotificationsBloc.initializeFCM();

  // Manejar notificaciones cuando la app está cerrada
  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  // Verificar si la app se abrió desde una notificación
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleInitialMessage(initialMessage);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        BlocProvider(create: (_) => NotificationsBloc()),
      ],
      child: const MainApp(),
    ),
  );
}

void _handleNotificationTap(RemoteMessage message) {
  print('📱 Notificación abierta: ${message.data}');
  // El manejo se hace en NotificationHandler widget
}

void _handleInitialMessage(RemoteMessage message) {
  print('📱 App abierta desde notificación: ${message.data}');
  // El manejo se hace en NotificationHandler widget
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return NotificationHandler(child: child!);
      },
    );
  }
}

/// Widget para manejar notificaciones en foreground
class NotificationHandler extends StatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  @override
  void initState() {
    super.initState();
    _setupForegroundNotifications();
  }

  void _setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Notificación en foreground: ${message.data}');

      final data = message.data;
      final type = data['type'];

      if (type == 'NEW_ORDER') {
        // Establecer pedido entrante en el provider (esto mostrará el modal)
        final orderProvider = context.read<OrderProvider>();
        orderProvider.setIncomingOrderFromNotification(data);
      }
    });

    // Manejar tap en notificación cuando la app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Tap en notificación (background): ${message.data}');

      final data = message.data;
      final type = data['type'];

      if (type == 'NEW_ORDER') {
        final orderProvider = context.read<OrderProvider>();
        orderProvider.setIncomingOrderFromNotification(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
