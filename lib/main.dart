import 'package:bol_food_app/config/config.dart';
import 'package:bol_food_app/config/router/app_router.dart';
import 'package:bol_food_app/notifications/bloc/notifications_bloc.dart';
import 'package:bol_food_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/legacy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsBloc.initializeFCM();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => NotificationsBloc())],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create:(_)=>AuthProvider())
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: AppTheme().getTheme(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
