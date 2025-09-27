import 'package:flutter/material.dart';
import 'package:flutter_frontend/feature/certificate/certificate_review_widget.dart';
import 'package:flutter_frontend/feature/logout/logout.controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_frontend/feature/user/user.controller.dart';
import 'package:flutter_frontend/feature/user/user.entity.dart';

class AppScaffold extends ConsumerWidget {
  final Widget body;

  const AppScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User> userState = ref.watch(userControllerProvider);
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: canPop ? null : _buildAppTitle(context, theme),
        leading: canPop ? _buildCloseButton(context) : null,
        actions: [
          // Certificate Review Badge
          CertificateReviewWidget(),

          const SizedBox(width: 8),

          // User Welcome & Profile
          _buildUserSection(context, userState, theme, ref),
        ],
      ),
      drawer: canPop ? null : _buildModernDrawer(context, theme, userState),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainer,
            ],
          ),
        ),
        child: body,
      ),
    );
  }

  Widget _buildAppTitle(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          GoRouter.of(context).go('/catalog');
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo icon
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/IconKleinTransparent.png',
              semanticLabel: 'Datenraum Logo',
            ),
          ),

          const SizedBox(width: 12),

          // Title text
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              children: [
                const TextSpan(text: 'Datenraum '),
                TextSpan(
                  text: 'Ostfriesland',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return IconButton(
      tooltip: 'Schließen',
      icon: const Icon(Icons.close_rounded),
      onPressed: () => GoRouter.of(context).pop(),
    );
  }

  Widget _buildUserSection(BuildContext context, AsyncValue<User> userState, ThemeData theme, WidgetRef ref) {
    return userState.when(
      data:
          (user) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Welcome message
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Willkommen,',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      user.firstName ?? 'Benutzer',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Profile button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  tooltip: 'Profil verwalten',
                  icon: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => GoRouter.of(context).push('/user'),
                ),
              ),

              const SizedBox(width: 8),

              // Logout button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  tooltip: 'Abmelden',
                  icon: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => _handleLogout(context, ref),
                ),
              ),
            ],
          ),
      loading:
          () => Container(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      error:
          (e, st) => IconButton(
            tooltip: 'Fehler beim Laden des Nutzers',
            icon: Icon(Icons.error_outline, color: theme.colorScheme.error),
            onPressed: () {
              // Could refresh user data or show error dialog
            },
          ),
    );
  }

  Widget _buildModernDrawer(BuildContext context, ThemeData theme, AsyncValue<User> _) {
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Modern Drawer Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Row(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/IconKleinTransparent.png',
                    height: 40,
                    semanticLabel: 'Datenraum Logo',
                  ),
                ),

                const SizedBox(width: 16),

                // Title and user info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datenraum',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ostfriesland',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: 'Datenkatalog',
                    subtitle: 'Verfügbare Datenquellen durchsuchen',
                    route: 'catalog',
                    theme: theme,
                  ),

                  const SizedBox(height: 8),

                  _buildDrawerItem(
                    context: context,
                    icon: Icons.shopping_cart_rounded,
                    title: 'Datenbedarf',
                    subtitle: 'Gesuchte Daten finden und anbieten',
                    route: 'dataRequests',
                    theme: theme,
                  ),

                  const SizedBox(height: 8),

                  _buildDrawerItem(
                    context: context,
                    icon: Icons.folder_rounded,
                    title: 'Meine Daten',
                    subtitle: 'Ihre bereitgestellten Datensätze',
                    route: 'myDatasets',
                    theme: theme,
                  ),

                  const Spacer(),

                  // Footer info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ostfriesischer Datenraum\nPrototyp v1.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required ThemeData theme,
  }) {
    final isCurrentRoute = GoRouterState.of(context).matchedLocation.contains(route);

    return Container(
      decoration: BoxDecoration(
        color: isCurrentRoute ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCurrentRoute ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isCurrentRoute ? Colors.white : theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isCurrentRoute ? FontWeight.w600 : FontWeight.w500,
            color: isCurrentRoute ? theme.colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        onTap: () {
          // Debug: Print the route we're trying to navigate to
          print('Navigating to route: $route');

          // Close drawer using the safest method
          Navigator.of(context).maybePop();

          // Navigate using GoRouter
          if (context.mounted) {
            try {
              GoRouter.of(context).goNamed(route);
            } catch (e) {
              print('Navigation error: $e');
              // Fallback: try go() instead of goNamed()
              final routePath = _getRoutePathFromName(route);
              if (routePath != null) {
                GoRouter.of(context).go(routePath);
              }
            }
          }
        },
      ),
    );
  }

  String? _getRoutePathFromName(String routeName) {
    switch (routeName) {
      case 'catalog':
        return '/catalog';
      case 'dataRequests':
        return '/dataRequests';
      case 'myDatasets':
        return '/myDatasets';
      case 'user':
        return '/user';
      case 'certificates_pending':
        return '/certificates/pending';
      default:
        return null;
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    try {
      final logoutController = ref.read(logoutControllerProvider.notifier);
      await logoutController.logout();
      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abmeldung fehlgeschlagen: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
