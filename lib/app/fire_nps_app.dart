import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../data/fire_nps_controller.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/auth/splash_page.dart';
import '../screens/home/root_shell.dart';
import '../theme/app_theme.dart';

void runFireNpsApp() {
  runApp(const FireNpsApp());
}

class FireNpsApp extends StatefulWidget {
  const FireNpsApp({super.key});

  @override
  State<FireNpsApp> createState() => _FireNpsAppState();
}

class _FireNpsAppState extends State<FireNpsApp> {
  late final FireNpsController controller;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late bool _wasAuthenticated;

  @override
  void initState() {
    super.initState();
    controller = FireNpsController();
    _wasAuthenticated = controller.isAuthenticated;
    controller.addListener(_handleAuthStateChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_handleAuthStateChanged);
    controller.dispose();
    super.dispose();
  }

  void _handleAuthStateChanged() {
    final navigator = navigatorKey.currentState;
    final isAuthenticated = controller.isAuthenticated;
    if (navigator == null || isAuthenticated == _wasAuthenticated) {
      return;
    }

    _wasAuthenticated = isAuthenticated;
    final routeName = isAuthenticated ? AppRoutes.home : AppRoutes.login;
    navigator.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FireNPS',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => SplashPage(controller: controller),
        AppRoutes.login: (_) => LoginPage(controller: controller),
        AppRoutes.register: (_) => RegisterPage(controller: controller),
        AppRoutes.home: (_) => RootShell(controller: controller),
      },
    );
  }
}
