import 'package:flutter_frontend/feature/catalog/catalog_screen.dart';
import 'package:flutter_frontend/feature/login/login_screen.dart';
import 'package:flutter_frontend/feature/scaffold/app_scaffold.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const AppScaffold(body: CatalogScreen()),
    ),
  ],
);
