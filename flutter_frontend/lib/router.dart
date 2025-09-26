import 'package:flutter_frontend/feature/catalog/catalog_screen.dart';
import 'package:flutter_frontend/feature/datasource_detail/datasource_detail.screen.dart';
import 'package:flutter_frontend/feature/login/login_screen.dart';
import 'package:flutter_frontend/feature/marketplace/data_requests.screen.dart';
import 'package:flutter_frontend/feature/scaffold/app_scaffold.dart';
import 'package:flutter_frontend/feature/user/user_profile_page.dart';
import 'package:flutter_frontend/feature/certificate/certificate_pending_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'initial',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) => const AppScaffold(body: CatalogScreen()),
      name: 'catalog',
    ),
    GoRoute(
      path: '/datasources/:id',
      name: 'datasources',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AppScaffold(body: DatasourceDetailScreen(datasourceId: id));
      },
    ),
    GoRoute(
      path: '/user',
      name: 'user',
      builder: (context, state) => const AppScaffold(body: UserProfilePage()),
    ),
    GoRoute(
      path: '/certificates/pending',
      name: 'certificates_pending',
      builder: (context, state) => AppScaffold(body: CertificatePendingPage()),
    ),
    GoRoute(
      path: '/datarequests',
      name: 'datarequests',
      builder: (context, state) => const AppScaffold(body: DataRequestsScreen()),
    ),
  ],
);
