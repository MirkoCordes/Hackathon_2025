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
    final LogoutController logoutController = ref.read(
      logoutControllerProvider.notifier,
    );

    final AsyncValue<User> state = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            Navigator.of(context).canPop()
                ? null
                : GestureDetector(
                  onTap: () {
                    if (context.mounted) {
                      GoRouter.of(context).go('/catalog');
                    }
                  },
                  child: Tooltip(
                    message: 'Startseite',
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Cascadia Code',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'Ostfriesland '),
                          const TextSpan(
                            text: 'Data',
                            style: TextStyle(color: Color(0xFFFF3838)),
                          ),
                          const TextSpan(
                            text: 'Hub',
                            style: TextStyle(color: Color(0xFF4242FF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        // Show a close (X) button on the leading side when this route can be popped.
        // That allows pushed routes (like /user) to be closed with an X.
        leading:
            Navigator.of(context).canPop()
                ? IconButton(
                  tooltip: 'Schließen',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )
                : Builder(
                  builder:
                      (context) => IconButton(
                        tooltip: 'Menü',
                        icon: Image.asset('assets/images/IconKleinTransparent.png'), // Custom icon path
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                ),
        actions: [
          // Certificate review icon - navigates to /certificates/review using push so it can be popped/closed
          CertificateReviewWidget(),

          // Welcome message left to the profile icon
          state.when(
            data:
                (displayUser) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Willkommen, ${displayUser.firstName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Fehler: $e')),
          ),

          // User profile icon - navigates to /user using push so it can be popped/closed
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person),
            onPressed: () async {
              // Push the user profile route so it can be closed (popped) with an X
              await GoRouter.of(context).push('/user');
            },
          ),
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logoutController.logout();
              if (context.mounted) {
                GoRouter.of(context).go('/');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFE9E9DD)),
              child: Image.asset('assets/images/logoLarge.png'),
            ),
            ListTile(
              title: const Text('Katalog'),
              onTap: () {
                if (context.mounted) {
                  GoRouter.of(context).goNamed('catalog');
                }
              },
            ),
            ListTile(
              title: const Text('Datenbedarf'),
              onTap: () {
                if (context.mounted) {
                  GoRouter.of(context).goNamed('dataRequests');
                }
              },
            ),
            ListTile(
              title: const Text('Meine Daten'),
              onTap: () {
                if (context.mounted) {
                  GoRouter.of(context).goNamed('myDatasets');
                }
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
